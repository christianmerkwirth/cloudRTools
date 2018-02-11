# A Spark-ready RStudio Server Docker Image

This directory contains code and instructions to build a
[Sparklyr](http://spark.rstudio.com/)-ready RStudio Server Docker image.

## Building and running the Docker image locally

From the root directory of this repo:
```bash
docker build -t sparklyrocker -f dockerfiles/rstudio-sparklyr/Dockerfile  .
docker run --rm -d -p 8787:8787 sparklyrocker:latest
````
