library(dplyr)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(sparklyr)
library(sparkgeo)
library(sparkbq)

# Setting environment vars for Spark.
Sys.setenv(SPARK_HOME="/usr/lib/spark")
Sys.setenv(JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre/")

# Spark configuration settings
config <- spark_config()

config$spark.executor.instances <- 2
config$park.executor.cores <- 2
config$spark.executor.memory <- "8g"
config$spark.sql.shuffle.partitions <- 400
config$spark.network.timeout <- 900
#config$spark.yarn.executor.memoryOverhead <- 2000

# Connect to spark on master node
sc <- spark_connect(master = "yarn-client",
                    config = config,
                    spark_home = "/usr/lib/spark",
                    app_name = "NYC TLC")

# Register sparkgeo's user-defined functions (UDFs)
sparkgeo_register(sc)


bigquery_defaults(
  billingProjectId = "river-vigil-178615",
  gcsBucket = "christianmerkwirth",
  datasetLocation = "US"
)

# Reading the public shakespeare data table
# https://cloud.google.com/bigquery/public-data/
# https://cloud.google.com/bigquery/sample-tables
hamlet <-
  spark_read_bigquery(
    sc,
    name = "shakespeare",
    projectId = "bigquery-public-data",
    datasetId = "samples",
    tableId = "shakespeare") %>%
  filter(corpus == "hamlet") %>% # NOTE: predicate pushdown to BigQuery!
  collect()





neighborhoods <-
  spark_read_geojson(
    sc = sc,
    name = "neighborhoods",
    path = "gs://miraisolutions/public/sparkgeo/nyc_neighborhoods.geojson"
  ) %>%
  mutate(neighborhood = metadata_string(metadata, "neighborhood")) %>%
  select(neighborhood, polygon, index) %>%
  sdf_persist()

all_trips_spark_by_year <-
  lapply(2009:2009, function(year) {
    spark_read_bigquery(
      sc = sc,
      name = paste0("trips", year),
      projectId = "bigquery-public-data",
      datasetId = "new_york",
      tableId = paste0("tlc_yellow_trips_", year),
      repartition = 400
    )
  })

# Union of all trip data
all_trips_spark <- Reduce(union_all, all_trips_spark_by_year)


credit_trips_spark <-
  all_trips_spark %>%
  filter(
    # Trips paid by credit card
    payment_type %in% c("CREDIT", "CRD", "1") &
    # Filter out bad data points
    fare_amount > 1 &
    tip_amount >= 0 &
    trip_distance > 0 &
    passenger_count > 0
  ) %>%
  # Select relevant columns only to reduce amount of data
  select(
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    pickup_latitude,
    pickup_longitude,
    trip_distance,
    passenger_count,
    fare_amount,
    tip_amount
  ) %>%
  # Join with NYC neighborhoods
  sparkgeo::sdf_spatial_join(neighborhoods, pickup_latitude,
                             pickup_longitude) %>%
  # NOTE: timestamps are currently returned as microseconds since the epoch
  mutate(
    trip_duration = (dropoff_datetime - pickup_datetime) / 1e6,
    pickup_datetime = from_unixtime(pickup_datetime / 1e6)
  ) %>%
  mutate(
    # Split pickup date/time into separate metrics
    pickup_month = month(pickup_datetime),
    pickup_weekday = date_format(pickup_datetime, 'EEEE'),
    pickup_hour = hour(pickup_datetime),
    # Calculate tip percentage based on fare amount
    tip_pct = tip_amount / fare_amount * 100
  ) %>%
  select(
    vendor_id,
    pickup_month,
    pickup_weekday,
    pickup_hour,
    neighborhood,
    trip_duration,
    trip_distance,
    passenger_count,
    fare_amount,
    tip_pct
  ) %>%
  # Persist results to memory and/or disk
  sdf_persist()


avg_tip_per_neighborhood_spark <-
credit_trips_spark %>%
group_by(neighborhood) %>%
summarize(avg_tip_pct = mean(tip_pct)) %>%
arrange(desc(avg_tip_pct))



avg_tip_per_neighborhood <- avg_tip_per_neighborhood_spark %>% collect()

head(avg_tip_per_neighborhood, n = 10)
