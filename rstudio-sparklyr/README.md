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
is to  download and run our custom Rstudio-Sparklyr Rocker image on a Dataproc cluster on Google Cloud during cluster setup. Later we
connect to RStudio using an SSH tunnel to the master node. Google also offers a Docker image build service which we invoke before
setting up the Dataproc cluster.


* Uploading a copy of the initialization action (`datalab.sh`) to [Google Cloud Storage](https://cloud.google.com/storage).
* Using the `gcloud` command to create a new cluster with this initialization action. The following command will create a new
cluster named `<CLUSTER_NAME>` and specify the initialization action stored in `<GCS_BUCKET>`.

    ```bash
    gcloud dataproc clusters create <CLUSTER_NAME> \
        --initialization-actions gs://<GCS_BUCKET>/rstudo-sparklyr/dataproc_initialization.sh \
        --scopes cloud-platform
    ```
* Once the cluster has been created, RStudio is configured to run on port `8787` on the **master** node in the Dataproc cluster.
To connect to the RStudio web interface, we will need to create an SSH tunnel and use a SOCKS 5 Proxy as described in the [dataproc web interfaces](https://cloud.google.com/dataproc/cluster-web-interfaces) documentation.
* Once we bring up RStudio there should be all necessary packages available in the Docker image to connect R to the Spark cluster.

You can find more information about using initialization actions with Dataproc in the [Dataproc documentation](https://cloud.google.com/dataproc/init-actions).

## Notes

* This script requires that RStudio runs on port `:8787`. If you normally run another server on that port, consider moving it. Note running multiple Spark sessions can consume a lot of cluster resources and can cause problems on moderately small clusters.
* If you [build your own Rocker images](https://github.com/googledatalab/datalab/wiki/Development-Environment), you can specify `--metadata=docker-image=gcr.io/<PROJECT>/<IMAGE>` to point to your image.
* You can pass Spark packages as a comma separated list with `--metadata spark-packages=<PACKAGES>` e.g. `--metadata '^#^spark-packages=com.databricks:spark-avro_2.11:3.2.0,graphframes:graphframes:0.3.0-spark2.0-s_2.11`.


## See also

[Jasper Ginn describes an alternative approach for running running Sparklyr on a Dataproc](https://www.jasperginn.nl/using-rstudio-and-sparklyr-with-a-google-dataproc-cluster/).
