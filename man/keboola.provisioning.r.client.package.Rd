\name{keboola.provisioning.r.client}
\alias{keboola.provisioning.r.client.package}
\docType{package}
\title{
Keboola Connection Provisioning client
}
\description{
Implementation of Keboola Connection Provisioning API client. The client allows easy access to API which 
provides credentials to transformation and sandbox buckets on both mysql and redshift backends.
}
\details{
\tabular{ll}{
Package: \tab keboola.provisioning.r.client\cr
Type: \tab Package\cr
Version: \tab 1.0\cr
Date: \tab 2015-04-28\cr
License: \tab MIT\cr
}
}
\author{
Maintainer: Ondrej Popelka <ondrej.popelka@keboola.com>
}
\keyword{ programming, database }
\examples{
\dontrun{
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
}
}

