# A set of tools for R for Big Data scenarios

## Sparklyr-ready Rocker Image

Use the Dockefile to build a [Rocker-based](https://github.com/rocker-org/rocker)
image that contains an RStudio Server with Spark&Sparklyr preinstalled.

```
docker build -t sparklyrocker .
docker run -d -p 8787:8787 sparklyrocker
````

Connect to [localhost:8787] and feel free to run the sparklyr_demo.R demo.

## TODO

Add code and instructions to build and run this image on Google Cloud connect
directly to a [dataproc cluster](https://cloud.google.com/dataproc/?hl=de), similar to these [instructions](https://www.jasperginn.nl/using-rstudio-and-sparklyr-with-a-google-dataproc-cluster/)
by Jasper Ginn.


## More R resources

[http://www.mjdenny.com/Rcpp_Intro.html]
[https://teuder.github.io/rcpp4everyone_en/]
