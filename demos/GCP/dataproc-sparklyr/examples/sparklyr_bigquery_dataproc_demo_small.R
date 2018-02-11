library(tidyverse)
library(sparklyr)
library(sparkbq)
library(feather)
# Add cloudml for wrappers to gcloud and gsutil cli.
library(cloudml)

# Make sure that cloudml finds gcloud and gsutil binaries.
system("ln -s /usr/lib/google-cloud-sdk/ ~/")

# Setting environment vars for Spark.
Sys.setenv(SPARK_HOME="/usr/lib/spark")
Sys.setenv(JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre/")

gcs.bucket <- "christianmerkwirth"

# Spark configuration settings
config <- spark_config()

# Connect to spark on master node
sc <- spark_connect(master = "yarn-client",
                    config = config,
                    spark_home = "/usr/lib/spark",
                    app_name = "NYC TLC")

bigquery_defaults(
  billingProjectId = "river-vigil-178615",
  gcsBucket = gcs.bucket,
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

# Persisting data on cloud storage. Use feather as an interoperable file format.
file.name <- "hamlet.feather"
write_feather(hamlet, file.name)
gs_copy(file.name, paste0("gs://", gcs.bucket, "/sparkbigquery_results/", file.name))
