library(dplyr)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(sparklyr)

config <- spark_config()
config[["spark.r.command"]] <- "/usr/bin/R"

sc <- spark_connect(master = "local")

trees_tbl <- sdf_copy_to(sc, trees, repartition = 2)

trees_tbl %>%
  spark_apply(function(e) scale(e))

iris_tbl <- copy_to(sc, iris)

spark_apply(
  iris_tbl,
  function(e) { broom::tidy(lm(Petal_Width ~ Petal_Length, e)) },
  names = c("term", "estimate", "std.error", "statistic", "p.value"),
  group_by = "Species"
)
