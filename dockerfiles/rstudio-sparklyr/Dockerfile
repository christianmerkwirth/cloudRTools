FROM rocker/tidyverse:3.4.3

RUN apt update && apt install r-cran-rjava -y \
  && apt-get install libc6-dbg gdb valgrind -y \
  && install2.r -r 'http://cran.rstudio.com' \
     devtools \
     Rcpp \
     caret \
     fst \
     feather \
     RANN \
     RcppAnnoy \
     testthat \
     xgboost \
     knitr \
     googleComputeEngineR \
     googleCloudStorageR \
     googleAuthR \
     googleAnalyticsR \
     searchConsoleR \
     bigrquery \
     bigQueryR \
     htmlwidgets \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
  && R -e 'devtools::install_github("rstudio/sparklyr")' \
  && R -e 'devtools::install_github("rstudio/cloudml")'  \
  && R -e 'devtools::install_github("miraisolutions/sparkbq", ref = "develop")' \
  && R -e 'devtools::install_github("miraisolutions/sparkgeo", ref = "develop")' \
  && R -e 'sparklyr::spark_install("2.2.0")'
COPY demo/ /home/rstudio/demo/
RUN mv /root/spark/ /home/rstudio/ && chown -R rstudio:rstudio /home/rstudio/ && rm -rf /tmp/*
ENV SPARK_HOME /home/rstudio/spark
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
