library(testthat)

# default values
KBC_TOKEN = 'yourToken'
KBC_RUNID = '123'
KBC_APIURL = 'https://syrup.keboola.com/provisioning'

# override with config if any
if (file.exists("config.R")) {
    source("config.R")
}

# override with environment if any
if (nchar(Sys.getenv("KBC_TOKEN")) > 0) {
    KBC_TOKEN <- Sys.getenv("KBC_TOKEN")  
}

test_check("keboola.provisioning.r.client")
