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
# a Dataproc cluster.

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
      ${VOLUME_FLAGS} ${DOCKER_IMAGE}; then
    echo 'RStudio docker image deployed.'
    exit
  fi

  echo 'Failed to run Cloud Datalab' >&2
  exit 1
fi
