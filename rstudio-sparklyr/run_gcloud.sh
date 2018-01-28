#!/usr/bin/env bash

PROJECT_ID="river-vigil-178615"
ROCKER_IMAGE="sparklyr_rocker"
CLUSTER_NAME="sparklyr-cluster"
REGION="global"
ZONE="europe-west3-c"
GCS_BUCKET="christianmerkwirth"
## If the command below fails, we most probably need to install and authenticate
## Gcloud CLI.
gcloud components update

## Create the Docker image
gcloud container builds submit --tag gcr.io/${PROJECT_ID}/${ROCKER_IMAGE} --timeout=1h .
gcloud container images list

IMAGE=gcr.io/${PROJECT_ID}/${ROCKER_IMAGE}:latest

gcloud container images  describe ${IMAGE}

gsutil cp dataproc_initialization.sh gs://${GCS_BUCKET}/rstudo-sparklyr/


## Create the dataproc cluster with given spec
gcloud beta dataproc \
  --region $REGION \
  clusters create sparklyr-cluster \
  --subnet default \
  --zone $ZONE \
  --master-machine-type n1-standard-2 \
  --master-boot-disk-size 500 \
  --num-workers 2 \
  --worker-machine-type n1-standard-2 \
  --worker-boot-disk-size 500 \
  --initialization-actions gs://${GCS_BUCKET}/rstudo-sparklyr/dataproc_initialization.sh \
  --scopes "https://www.googleapis.com/auth/cloud-platform" \
  --project river-vigil-178615 \
  --metadata=docker-image=$IMAGE \
  --max-idle 7200


# gcloud dataproc clusters describe $CLUSTER_NAME
# gcloud compute --project "river-vigil-178615" ssh --zone "us-central1-f" "sparklyr-cluster-m"  -- -D 8787 -N -n
# gcloud compute --project "river-vigil-178615" ssh --zone "us-central1-f" "sparklyr-cluster-m"  -- -N -L 8082:sparklyr-cluster-m:8787
## OR:

# gcloud compute --project "river-vigil-178615" ssh --zone "us-central1-f" "sparklyr-cluster-m"  -- -D 1080 -N -n

#/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
#--proxy-server="socks5://localhost:1080" \
#--host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" \
#--user-data-dir=/tmp/sparklyr-cluster-m


## Run Rstudio from the freshly created Docker image on the Dataproc master.

## Now we can log into the localhost:8787 and continue there with R commands.
## logn: rstudio, password: rstudio

#gcloud dataproc clusters update example-cluster --num-workers 5
#gcloud dataproc clusters update example-cluster --num-workers 2

#    gcloud dataproc clusters delete $CLUSTER_NAME --region=${REGION}
