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

# In this first example we spark_apply a function that only uses
# R base commands.
trees_tbl <- sdf_copy_to(sc, trees, repartition = 2, overwrite = TRUE)

trees_tbl %>%
  spark_apply(function(e) scale(e))

# In this second example we spark_apply a function that uses commands from
# the broom package, which will be serialized from the R installation on the
# master node to the worker nodes.
iris_tbl <- copy_to(sc, iris, repartition = 2, overwrite = TRUE)

iris_func <- function(e) {
  if (!("broom" %in% installed.packages())) {
    install.packages("broom")
  }
  library(broom)
  broom::tidy(lm(Petal_Width ~ Petal_Length, e))
}

spark_apply(
  iris_tbl,
  iris_func,
  names = c("term", "estimate", "std.error", "statistic", "p.value"),
  group_by = "Species"
)
