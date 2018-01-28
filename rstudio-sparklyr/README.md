# A Spark-ready RStudio Server Docker Image

This directory contains code and instructions to build a Spark-ready RStudio Server Docker image.

## Building and running the Docker image locally

```bash
cd rstudio-sparklyr
docker build -t sparklyrocker .
docker run --rm -d -p 8787:8787 sparklyrocker:latest
````

## Running an Rstudio-Server with Sparklyr on a Google Dataproc cluster

Google Cloud offers managed Spark clusters named [dataproc clusters](https://cloud.google.com/dataproc/?hl=en). The main idea there
is to  download and run our custom Rstudio-Sparklyr Rocker image on a Dataproc master node during cluster setup. Later we
connect to RStudio on the Dataproc master node using an SSH tunnel. Google also offers a Docker image build service which we happily
use to build our Rstudio-Sparklyr Rocker before setting up the Dataproc cluster.

## Quickstart

Before running this script, make sure that you have Google Cloud CLI tools installed and authenticated to your Google Cloud account.
You need to have a project set up on GCloud with sufficient billing. Note that significant costs may occur depending on the usage.
Please remember to delete any GCloud resources not longer in use.

If you feel confident to proceed, edit and run the run_gcloud script.
```bash
source run_gcloud.sh
```

Once the Dataproc cluster is created, RStudio should run on the master node, listening to port `8787`. There are several
possibilites to connect:

* **SUPER UNSAFE** Create a project wide firewall exception for port 8787  to connect with your browser to the external IP of the master node.
* Create an SSH tunnel and use a SOCKS 5 Proxy as described in the [dataproc web interfaces](https://cloud.google.com/dataproc/cluster-web-interfaces) documentation.
* SSH tunneling of port 8787.

RStudio should have be all necessary packages onboard to connect to the Spark cluster. See the provided demos for details.

## Notes

* This script requires that RStudio runs on port `:8787`. If you normally run another server on that port, consider moving it. Note running multiple Spark sessions can consume a lot of cluster resources and can cause problems on moderately small clusters.
* If you [build your own Rocker images](https://github.com/googledatalab/datalab/wiki/Development-Environment), you can specify `--metadata=docker-image=gcr.io/<PROJECT>/<IMAGE>` to point to your image.
* You can pass Spark packages as a comma separated list with `--metadata spark-packages=<PACKAGES>` e.g. `--metadata '^#^spark-packages=com.databricks:spark-avro_2.11:3.2.0,graphframes:graphframes:0.3.0-spark2.0-s_2.11`.
* You can find more information about using initialization actions with Dataproc in the [Dataproc documentation](https://cloud.google.com/dataproc/init-actions).

## See also

[Jasper Ginn describes an alternative approach for running running Sparklyr on a Dataproc](https://www.jasperginn.nl/using-rstudio-and-sparklyr-with-a-google-dataproc-cluster/).
