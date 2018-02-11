# CloudRTools - Info and tools for working with R in the Cloud

## Overview

R is an increasingly popular, powerful and versatile platform for data science. R started as a standalone
application limited to the resources available on single machine. But even a modern powerful machine does not
always provide enough CPU and memory for the today's big data challenges.

Luckily, there is a number of cloud platform that provide virtually unlimited compute and storage resources. We
focus here on three providers:

* [Google Cloud Platform (GCP)](https://cloud.google.com/)
* [Amazon AWS](https://aws.amazon.com/)
* [Microsoft Azure](https://azure.microsoft.com/)

However, working with R in the Cloud is not always trivial for several reasons:

* Account and technical setup on the user side.
* Deciding which kind of parallelization approach is needed for the given task.
* Implementation and task orchestration.

In the last few years fortunately many R packages have been written that drastically lower
the barrier of connecting R to the cloud.

Still, in most cases there are several viable approaches, which can differ in terms of complexity, robustness
and costs. At the time of writing this there is not very concise information about the various
possibilities. This repo tries to bring some light into this jungle by providing examples and
infos how to work R with the Cloud.

## Easy and hard parallelization

Most big data problems fall into two classes:

* Easy parallelization is when the workload can trivally be split into tasks. Example: Applying the same filter function to 100k images, where each image is treated independently of all others.
* Hard parallelization is when the workload does not allow for such a trival task splitting. Example: Train a machine learning model
on billions of rows and millions of columns.

Though even the *easy* problems can be difficult when it comes to the orchestration of a large number of workers, for the
*hard* problems it is mandatory to rely on cluster processing frameworks:

* Flow processing frameworks  (e.g. Map-Reduce, Flume)
* Query processing frameworks (e.g. BigQuery)

Flow processing frameworks allow the user to describe a sequence of processing steps that will be executed on a distributed data set. While the framework might compile an optimized execution plan, using these framework is still
closer to a traditional programming paradigm.

Query processing frameworks execute SQL-like queries against a specially formatted data set. While those frameworks limit
the scope of algorithms that can be applied on that data, their advantage is that they are fully managed and are able
to handle extremely large data sets.

Often the solution to a given problem can involve the combination of different approaches, e.g. filtering and aggregating
the intial, extremely huge data set by means of a query processing framework and then executing a more complex
machine learning algorithm on the already reduced data set.

## Docker images

### Small-footprint base R images

```
cd alpine
docker build -t alpine-base .
docker run -it --rm alpine-base:latest
````

### Sparklyr-ready Rstudio Rocker Image

Use the Dockefile to build a [Rocker-based](https://github.com/rocker-org/rocker)
image that contains an RStudio Server with Spark&Sparklyr preinstalled.

```
cd rstudio-sparklyr
docker build -t sparklyrocker .
docker run --rm -d -p 8787:8787 sparklyrocker:latest
````

Connect to [localhost:8787](localhost:8787) and feel free to run the
`sparklyr_local_demo.R` demo.


## More R Cloud resources

* [R and the web](https://cran.r-project.org/web/views/WebTechnologies.html)
* [Cloudyr](https://cloudyr.github.io/)
* [Sparklyr](http://spark.rstudio.com/)
* [http://www.mjdenny.com/Rcpp_Intro.html]
* [https://teuder.github.io/rcpp4everyone_en/]
