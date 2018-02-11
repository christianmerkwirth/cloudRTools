# A Spark-ready RStudio Server Docker Image

This directory contains code and instructions to build a
[Sparklyr](http://spark.rstudio.com/)-ready RStudio Server Docker image.

## Building and running the Docker image locally

```bash
cd rstudio-sparklyr
docker build -t sparklyrocker .
docker run --rm -d -p 8787:8787 sparklyrocker:latest
````

## Running an Rstudio-Server with Sparklyr on a Google Dataproc cluster

Google Cloud offers managed Spark clusters named [dataproc clusters](https://cloud.google.com/dataproc/?hl=en).

The main idea of this project is to use Google Dataproc as super fast and convenient option to set up a Spark cluster.
During setup of the cluster, the initialization script will automatically download and run our custom
Rstudio-Sparklyr Rocker image on a Dataproc master node during cluster setup. Later we connect to the RStudio Server
on the Dataproc master node using an SSH tunnel. Thus we get R running in the cloud, attached to a managed,
scalable Spark cluster. We pay only for the minutes the Spark cluster is up and running. After doing computations,
we delete the cluster to avoid any additional costs.

Google also offers a Docker image build service which we happily use to build our Rstudio-Sparklyr Rocker
before setting up the Dataproc cluster.

## Prereqs

Before running this script, make sure that:

* You have a Google Cloud account.
* You have a project set up on GCloud with sufficient billing.
* You choose a region and a zone.
* You create a Google Storage bucket for the setup files.
* You are familiar with nagivation the Google Cloud console.
* You have [Google Cloud SDK](https://cloud.google.com/sdk/) tools installed, configured and authenticated.

## Quickstart

Note that significant costs may occur depending on the usage. Please remember to delete any GCloud resources not longer in use.
If you feel confident to proceed, clone this github repo, *edit and run the run_gcloud script*.

```bash
cd rstudio-sparklyr
source run_gcloud.sh
```

Once the Dataproc cluster is created, RStudio should run on the master node, listening to port `8787`. There are several
possibilites to connect:

* **SUPER UNSAFE** Create a project wide firewall exception for port 8787  to connect with your browser to the external IP of the master node.
* Create an SSH tunnel and use a SOCKS 5 Proxy as described in the [dataproc web interfaces](https://cloud.google.com/dataproc/cluster-web-interfaces) documentation.
* SSH tunneling of port 8787.

RStudio should have be all necessary packages onboard to connect to the Spark cluster. See the provided demos for details.

Within the RStudio session on the Dataproc master node, run:
```R
source('demo/sparklyr_dataproc_demo.R')
```

## What happens under the hood ?

So the `run_gloud.sh` file builds a Dockerfile with RStudio, R 3.4.3 and lots of useful packages. It then
creates a dataproc cluster and

* installs and runs the RStudio docker on the master node.
* installs or upgrades R base 3.4.3 on all worker nodes. For spark_apply it is essential that the R versions
on the master and on the worker nodes agree.

## Getting data in and about

**DRAFT**
Since both the Dataproc cluster and the Docker container running RStudio are epheremal, we need a way to get input data
into and result data out. Google Cloud storage seems the ideal way of persisting data. Two R packages seem promising here:

* [googleCloudStorageR](https://github.com/cloudyr/googleCloudStorageR)
* [googleComputeEngineR](https://github.com/cloudyr/googleComputeEngineR)

## Notes

* This script requires that RStudio runs on port `:8787`. If you normally run another server on that port, consider moving it. Note running multiple Spark sessions can consume a lot of cluster resources and can cause problems on moderately small clusters.
* If you [build your own Rocker images](https://github.com/googledatalab/datalab/wiki/Development-Environment), you can specify `--metadata=docker-image=gcr.io/<PROJECT>/<IMAGE>` to point to your image.
* You can pass Spark packages as a comma separated list with `--metadata spark-packages=<PACKAGES>` e.g. `--metadata '^#^spark-packages=com.databricks:spark-avro_2.11:3.2.0,graphframes:graphframes:0.3.0-spark2.0-s_2.11`.
* You can find more information about using initialization actions with Dataproc in the [Dataproc documentation](https://cloud.google.com/dataproc/init-actions).

## See also

[Jasper Ginn describes an alternative approach for running running Sparklyr on a Dataproc](https://www.jasperginn.nl/using-rstudio-and-sparklyr-with-a-google-dataproc-cluster/).
