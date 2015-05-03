# Provisioning R Client

[![Build Status](https://travis-ci.org/keboola/provisioning-r-client.svg?branch=master)](https://travis-ci.org/keboola/provisioning-r-client)

Client for using [Keboola Connection Provisioning API](http://docs.provisioningapi.apiary.io/). This API client 
provides credentials to transformation and sanbox databases.

## Examples
```
# create client
client <- ProvisioningClient$new(
    backend = 'redshift',
    token = 'your-KBC-token'
)
credentials <- client$getCredentials()$credentials

# verify that the credentials actually work
db <- RedshiftDriver$new()
db$connect(
    credentials$host, 
    credentials$db, 
    credentials$user, 
    credentials$password, 
    credentials$schema
) 
```

First argument to ProvisioningClient constructor is database backend, which may be either mysql or redshift. Second argument is Storage API token.
