FROM rocker/tidyverse:latest

RUN apt update && apt install r-cran-rjava -y
RUN apt-get install libc6-dbg gdb valgrind -y

RUN install2.r \
    devtools \
    caret \
    fst \
    RANN \
    RcppAnnoy \
    testthat \
    xgboost \
    knitr

RUN R -e 'devtools::install_github("rstudio/sparklyr")'
RUN R -e 'sparklyr::spark_install("2.2.0")'
RUN mv /root/spark/ /home/rstudio/
COPY *.R /home/rstudio/demo/
RUN chown -R rstudio:rstudio /home/rstudio/
ENV SPARK_HOME /home/rstudio/spark
