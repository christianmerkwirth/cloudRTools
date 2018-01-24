FROM rocker/tidyverse:latest

RUN apt update && apt install r-cran-rjava -y && \
    apt-get install libc6-dbg gdb valgrind -y && install2.r \
        devtools \
        caret \
        fst \
        RANN \
        RcppAnnoy \
        testthat \
        xgboost \
        knitr && \
    apt-get clean && \
    R -e 'devtools::install_github("rstudio/sparklyr")' &&  R -e 'sparklyr::spark_install("2.2.0")'
COPY *.R /home/rstudio/demo/
RUN mv /root/spark/ /home/rstudio/ && chown -R rstudio:rstudio /home/rstudio/ && rm -rf /tmp/*
ENV SPARK_HOME /home/rstudio/spark
