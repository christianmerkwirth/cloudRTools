#!/usr/bin/env bash

## Before running this script, make sure:
## You have Google Cloud CLI tools installed and configured.
## You have a project set up on GCloud with sufficient billing. Note that
## significant costs may occurr depending on the usage. Please remember to
## delete any resources not longer in use.

## Adapt PROJECT_ID, REGION, ZONE AND GCS_BUCKET with your data.
PROJECT_ID="river-vigil-178615"
CLUSTER_NAME="sparklyr-cluster"
REGION="global"
ZONE="europe-west3-c"
GCS_BUCKET="christianmerkwirth"

## If the command below fails, we most probably need to install and authenticate
## Gcloud CLI.
gcloud components update

## The Docker image is already hosted on gcr. GCloud claims that first 120 min
##of build time each day are free.
IMAGE=gcr.io/github-christianmerkwirth-cloudrtools:latest

## Make sure we see a description of the freshly created image here.
gcloud container images  describe ${IMAGE}

## Though small, we need to copy the dataproc_initialization action script to
## a cloud bucket in order to make it available when setting up the dataproc
## cluster.
gsutil cp dataproc_initialization.sh gs://${GCS_BUCKET}/rstudio-sparklyr/

## Create the dataproc cluster with given specs. Note the init actions and the
## metadata provided. This will start Rstudio inside the Rocker image on the
# Dataproc master.
gcloud beta dataproc \
  --region ${REGION} \
  clusters create sparklyr-cluster \
  --subnet default \
  --zone ${ZONE} \
  --master-machine-type n1-standard-2 \
  --master-boot-disk-size 500 \
  --num-workers 3 \
  --worker-machine-type n1-highmem-2 \
  --master-boot-disk-size 30 \
  --worker-boot-disk-size 30 \
  --initialization-actions gs://${GCS_BUCKET}/rstudio-sparklyr/dataproc_initialization.sh \
  --scopes "https://www.googleapis.com/auth/cloud-platform" \
  --scopes cloud-platform \
  --project ${PROJECT_ID} \
  --metadata=docker-image=${IMAGE} \
  --max-idle 7200
