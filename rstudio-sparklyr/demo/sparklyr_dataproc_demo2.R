library(sparklyr)
library(dplyr)
library(tidyverse)
library(lubridate)
library(ggplot2)

# Setting environment vars for Spark.
Sys.setenv(SPARK_HOME="/usr/lib/spark")
Sys.setenv(JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre/")

config <- spark_config()

# Connect to spark on master node
sc <- spark_connect(master = "yarn-client", spark_home = "/usr/lib/spark")

spark_read_csv(sc,
               "flights_spark_2006",
               "gs://christianmerkwirth/rstudio-sparklyr/dataexpo/2009/2006.csv.bz2",
               memory = TRUE,
               overwrite = TRUE)

spark_read_csv(sc,
               "flights_spark_2007",
               "gs://christianmerkwirth/rstudio-sparklyr/dataexpo/2009/2007.csv.bz2",
               memory = TRUE,
               overwrite = TRUE)

spark_read_csv(sc,
               "flights_spark_2008",
               "gs://christianmerkwirth/rstudio-sparklyr/dataexpo/2009/2008.csv.bz2",
               memory = TRUE,
               overwrite = TRUE)

spark_read_csv(sc,
              "airlines",
              "gs://christianmerkwirth/rstudio-sparklyr/airlines.csv",
              memory = TRUE,
              overwrite = TRUE)

spark_read_csv(sc,
              "airports",
              "gs://christianmerkwirth/rstudio-sparklyr/airports.csv",
              memory = TRUE,
              overwrite = TRUE)

# Cache airlines Hive table into Spark
airlines_tbl <- tbl(sc, 'airlines')

# Cache airports Hive table into Spark
airports_tbl <- tbl(sc, 'airports')

# Union all flights.
flights_tbl <-  dplyr::union(
    tbl(sc, 'flights_spark_2007'),
    tbl(sc, 'flights_spark_2008'),
    tbl(sc, 'flights_spark_2009'))

# Filter records and create target variable 'gain'
model_data <- flights_tbl %>%
  dplyr::filter(!is.na(arrdelay) & !is.na(depdelay) & !is.na(distance)) %>%
  dplyr::filter(depdelay > 15 & depdelay < 240) %>%
  dplyr::filter(arrdelay > -60 & arrdelay < 360) %>%
  dplyr::filter(year >= 2003 & year <= 2007) %>%
  dplyr::left_join(airlines_tbl, by = c("uniquecarrier" = "code")) %>%
  dplyr::mutate(gain = depdelay - arrdelay) %>%
  dplyr::select(year, month, arrdelay, depdelay, distance, uniquecarrier, description, gain)

# Summarize data by carrier
model_data %>%
  dplyr::group_by(uniquecarrier) %>%
  dplyr::summarize(description = min(description), gain=mean(gain),
            distance=mean(distance), depdelay=mean(depdelay)) %>%
  dplyr::select(description, gain, distance, depdelay) %>%
  dplyr::arrange(gain)

  # Partition the data into training and validation sets
model_partition <- model_data %>%
  sdf_partition(train = 0.8, valid = 0.2, seed = 5555)

# Fit a linear model
ml1 <- model_partition$train %>%
  ml_linear_regression(gain ~ distance + depdelay + uniquecarrier)

# Summarize the linear model
print(summary(ml1))

# Calculate average gains by predicted decile
model_deciles <- lapply(model_partition, function(x) {
  sdf_predict(ml1, x) %>%
    dplyr::mutate(decile = ntile(desc(prediction), 10)) %>%
    dplyr::group_by(decile) %>%
    dplyr::summarize(gain = mean(gain)) %>%
    dplyr::select(decile, gain) %>%
    dplyr::collect()
})

# Create a summary dataset for plotting
deciles <- rbind(
  data.frame(data = 'train', model_deciles$train),
  data.frame(data = 'valid', model_deciles$valid),
  make.row.names = FALSE
)

# Plot average gains by predicted decile
g <- deciles %>%
  ggplot(aes(factor(decile), gain, fill = data)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  labs(title = 'Average gain by predicted decile', x = 'Decile', y = 'Minutes')
print(g)

# Select data from an out of time sample
data_2008 <- flights_tbl %>%
  dplyr::filter(!is.na(arrdelay) & !is.na(depdelay) & !is.na(distance)) %>%
  dplyr::filter(depdelay > 15 & depdelay < 240) %>%
  dplyr::filter(arrdelay > -60 & arrdelay < 360) %>%
  dplyr::filter(year == 2008) %>%
  dplyr::left_join(airlines_tbl, by = c("uniquecarrier" = "code")) %>%
  dplyr::mutate(gain = depdelay - arrdelay) %>%
  dplyr::select(year, month, arrdelay, depdelay, distance, uniquecarrier, description, gain, origin,dest)

# Summarize data by carrier
carrier <- sdf_predict(ml1, data_2008) %>%
  dplyr::group_by(description) %>%
  dplyr::summarize(gain = mean(gain), prediction = mean(prediction), freq = n()) %>%
  dplyr::filter(freq > 10000) %>%
  dplyr::collect()

# Plot actual gains and predicted gains by airline carrier
g <- ggplot(carrier, aes(gain, prediction)) +
  geom_point(alpha = 0.75, color = 'red', shape = 3) +
  geom_abline(intercept = 0, slope = 1, alpha = 0.15, color = 'blue') +
  geom_text(aes(label = substr(description, 1, 20)), size = 3, alpha = 0.75, vjust = -1) +
  labs(title='Average Gains Forecast', x = 'Actual', y = 'Predicted')
print(g)

# Summarize by origin, destination, and carrier
summary_2008 <- sdf_predict(ml1, data_2008) %>%
  dplyr::rename(carrier = uniquecarrier, airline = description) %>%
  dplyr::group_by(origin, dest, carrier, airline) %>%
  dplyr::summarize(
    flights = n(),
    distance = mean(distance),
    avg_dep_delay = mean(depdelay),
    avg_arr_delay = mean(arrdelay),
    avg_gain = mean(gain),
    pred_gain = mean(prediction)
    )

# Collect and save objects
pred_data <- collect(summary_2008)
airports <- collect(select(airports_tbl, name, faa, lat, lon))
ml1_summary <- capture.output(summary(ml1))
save(pred_data, airports, ml1_summary, file = 'flights_pred_2008.RData')
