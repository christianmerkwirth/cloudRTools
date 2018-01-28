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

iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)

# filter by departure delay and print the first few records
flights_tbl %>% filter(dep_delay == 2)

delay <- flights_tbl %>%
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect

# plot delays
g <- ggplot(delay, aes(x = dist, y = delay))

g <- g + geom_point(aes(size = count, col = count), alpha = 1/2)
print(g)

g <- g + geom_smooth()
print(g)

g<- g + scale_size_area(max_size = 2)
print(g)

ggsave(filename = 'gpplot_example.pdf', plot = g)
