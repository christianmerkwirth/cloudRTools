#!/usr/bin/env bash

## Before running this script, make sure:
## You have Google Cloud CLI tools installed and configured.
## You have a project set up on GCloud with sufficient billing. Note that
## significant costs may occurr depending on the usage. Please remember to
## delete any resources not longer in use.

## Adapt PROJECT_ID, REGION, ZONE AND GCS_BUCKET with your data.
PROJECT_ID="river-vigil-178615"
ROCKER_IMAGE="sparklyr_rocker"
CLUSTER_NAME="sparklyr-cluster"
REGION="global"
ZONE="europe-west3-c"
GCS_BUCKET="christianmerkwirth"

## If the command below fails, we most probably need to install and authenticate
## Gcloud CLI.
gcloud components update

## Build the Rocker image. GCloud claims that first 120 min of build time of a
# day are free.
IMAGE=gcr.io/${PROJECT_ID}/${ROCKER_IMAGE}:latest
#gcloud container builds submit --tag gcr.io/${PROJECT_ID}/${ROCKER_IMAGE} --timeout=1h .

## Make sure we see a description of the freshly created image here.
gcloud container images  describe ${IMAGE}

## Though small, we need to copy the dataproc_initialization action script to
## a cloud bucket in order to make it available when setting up the dataproc
## cluster.
gsutil cp dataproc_initialization.sh gs://${GCS_BUCKET}/rstudo-sparklyr/

## Create the dataproc cluster with given specs. Note the init actions and the
## metadata provided. This will start Rstudio inside the Rocker image on the
# Dataproc master.
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
# gcloud compute --project $PROJECT ssh --zone $ZONE" ${CLUSTER_NAME}-m  -- -D 8787 -N -n
# gcloud compute --project "river-vigil-178615" ssh --zone $ZONE "sparklyr-cluster-m"  -- -N -L 8082:sparklyr-cluster-m:8787
## OR:

# gcloud compute --project "river-vigil-178615" ssh --zone "us-central1-f" "sparklyr-cluster-m"  -- -D 1080 -N -n

#/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
#--proxy-server="socks5://localhost:1080" \
#--host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" \
#--user-data-dir=/tmp/sparklyr-cluster-m

## Now we can log into the localhost:8787 and continue there with R commands.
## login: rstudio, password: rstudio



## Remember to take down the cluster when not longer in use to avoid
## additional costs.
## gcloud dataproc clusters delete $CLUSTER_NAME --region=${REGION}
