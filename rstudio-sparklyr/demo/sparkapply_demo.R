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


trees_tbl <- sdf_copy_to(sc, trees, repartition = 2, overwrite = TRUE)

trees_tbl %>%
  spark_apply(function(e) scale(e))

iris_tbl <- copy_to(sc, iris, repartition = 2, overwrite = TRUE)

spark_apply(
  iris_tbl,
  function(e) { broom::tidy(lm(Petal_Width ~ Petal_Length, e)) },
  names = c("term", "estimate", "std.error", "statistic", "p.value"),
  group_by = "Species"
)
