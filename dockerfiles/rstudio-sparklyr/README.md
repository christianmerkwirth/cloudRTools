# A Spark-ready RStudio Server Docker Image

This directory contains code and instructions to build a
[Sparklyr](http://spark.rstudio.com/)-ready RStudio Server Docker image.

## Building and running the Docker image locally

```bash
docker build -t sparklyrocker .
docker run --rm -d -p 8787:8787 sparklyrocker:latest
````

