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

spark_read_csv(sc, "flights_spark_2008", "gs://christianmerkwirth/rstudo-sparklyr/dataexpo/2009/2008.csv.bz2", memory = FALSE)

flights_table <- tbl(sc,"flights_spark_2008") %>%
  mutate(DepDelay = as.numeric(DepDelay),
         ArrDelay = as.numeric(ArrDelay),
         DepDelay > 15 , DepDelay < 240,
         ArrDelay > -60 , ArrDelay < 360,
         Gain = DepDelay - ArrDelay) %>%
  filter(ArrDelay > 0) %>%
  select(Origin, Dest, UniqueCarrier, Distance, DepDelay, ArrDelay, Gain)

sdf_register(flights_table, "flights_spark")

tbl_cache(sc, "flights_spark")

spark_read_csv(sc, "flights_spark_2007" , "gs://christianmerkwirth/rstudo-sparklyr/dataexpo/2009/2007.csv.bz2", memory = FALSE)

all_flights <- tbl(sc, "flights_spark_2008") %>%
  union(tbl(sc, "flights_spark_2007")) %>%
  group_by(Year, Month) %>%
  tally()

all_flights <- all_flights %>%
  collect()

ggplot(data = all_flights, aes(x = Month, y = n/1000, fill = factor(Year))) +
  geom_area(position = "dodge", alpha = 0.5) +
  geom_line(alpha = 0.4) +
  scale_fill_brewer(palette = "Dark2", name = "Year") +
  scale_x_continuous(breaks = 1:12, labels = c("J","F","M","A","M","J","J","A","S","O","N","D")) +
  theme_light() +
  labs(y="Number of Flights (Thousands)", title = "Number of Flights Year-Over-Year")
