#!/bin/bash
# Copyright 2018 Christian Merkwirth
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This init script installs a RStudio server Docker image on the master node of
# a Dataproc cluster and R base on each worker node. Use this script if you
# intend to use spark_apply.

set -e -x

ROLE=$(/usr/share/google/get_metadata_value attributes/dataproc-role)
PROJECT=$(/usr/share/google/get_metadata_value ../project/project-id)
DOCKER_IMAGE=$(/usr/share/google/get_metadata_value attributes/docker-image || true)
SPARK_PACKAGES=$(/usr/share/google/get_metadata_value attributes/spark-packages || true)

if [[ "${ROLE}" == 'Master' ]]; then
  apt-get update
  apt-get install -y -q docker.io
  if [[ -z "${DOCKER_IMAGE}" ]]; then
    DOCKER_IMAGE="gcr.io/river-vigil-178615/sparklyr_rocker:latest"
  fi
  gcloud docker -- pull ${DOCKER_IMAGE}

  useradd rstudio
  echo "rstudio:rstudio" | chpasswd
	mkdir /home/rstudio
	chown rstudio:rstudio /home/rstudio
	addgroup rstudio staff

  # Expose every possible spark configuration and lib directory from the host
  # o the container. Fortunately both host and Docker base are Debian.
  VOLUMES=$(echo /etc/{hadoop*,hive*,*spark*}  \
           /etc/alternatives/{hadoop*,hive*,*spark*} \
           /hadoop \
           /usr/lib/spark \
           /usr/lib/hadoop/ \
           /usr/lib/hadoop-hdfs \
           /usr/lib/hadoop-mapreduce \
           /usr/lib/hadoop-yarn \
           /usr/lib/hive)

  VOLUME_FLAGS=$(echo ${VOLUMES} | sed 's/\S*/-v &:&/g')
  echo "VOLUME_FLAGS: ${VOLUME_FLAGS}"

  # Docker gives a "too many symlinks" error if volumes are not yet automounted.
  # Ensure that the volumes are mounted to avoid the error.
  # We explicitely mount the Spark and Hadoop directories on the host machine.
  # Our image has a local spark installation under /home/rstudio/spark which
  # should not interfere with this.
  touch ${VOLUMES}
  if docker run -d --restart always --net=host \
      -v /home/rstudio:/host/home/rstudio \
      ${VOLUME_FLAGS} ${DOCKER_IMAGE}; then
    echo 'RStudio docker image deployed.'
    exit
  fi

  echo 'Failed to run Cloud Datalab' >&2
  exit 1
fi
## Upgrade base-R with to 3.4.3 on worker nodes to enable spark_apply.
if [[ "${ROLE}" == 'Worker' ]]; then
  echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list
  export R_BASE_VERSION=3.4.3

  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

  ## Install or upgrade base-R with to 3.4.3
  export DEBIAN_FRONTEND=noninteractive
  apt-get update \
  	&& apt-get install -t unstable -y --no-install-recommends \
    r-base=${R_BASE_VERSION}*
    #r-base-dev=${R_BASE_VERSION}* \
    #r-recommended=${R_BASE_VERSION}*

  echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site
fi
