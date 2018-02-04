library(googleComputeEngineR)


vm <- gce_vm(template = "rstudio",
             name = "rstudio-server",
             username = "rstudio",
             password = "rstudio",
             predefined_type = "n1-standard-2")


