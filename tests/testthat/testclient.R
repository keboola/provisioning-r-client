devtools::install_github('keboola/redshift-r-client', ref = 'master')

# include redshift client for actually testing that the provided credentials are valid
library('keboola.redshift.r.client')

test_that("getCredentials", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    credentials <- client$getCredentials()
    
    # verify credentials structure
    expect_false(is.null(credentials$credentials))
    expect_false(is.null(credentials$credentials$hostname))
    expect_false(is.null(credentials$credentials$db))
    expect_false(is.null(credentials$credentials$user))
    expect_false(is.null(credentials$credentials$password))
    expect_false(is.null(credentials$credentials$schema))
    expect_false(is.null(credentials$credentials$id))
    
    # verify that the credentials actually work
    credentials = credentials$credentials
    db <- RedshiftDriver$new()
    expect_equal(
        db$connect(
            credentials$host, 
            credentials$db, 
            credentials$user, 
            credentials$password, 
            credentials$schema
        ),
        TRUE
    )
    db$select("SELECT 1");
    client$dropCredentials(credentials$id)
})


test_that("getCredentialsSandbox", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    credentials <- client$getCredentials('sandbox')
    
    # verify credentials structure
    expect_false(is.null(credentials$credentials))
    expect_false(is.null(credentials$credentials$hostname))
    expect_false(is.null(credentials$credentials$db))
    expect_false(is.null(credentials$credentials$user))
    expect_false(is.null(credentials$credentials$password))
    expect_false(is.null(credentials$credentials$schema))
    expect_false(is.null(credentials$credentials$id))
            
    # verify that the credentials actually work
    credentials = credentials$credentials
    db <- RedshiftDriver$new()
    expect_equal(
        db$connect(
            credentials$host, 
            credentials$db, 
            credentials$user, 
            credentials$password, 
            credentials$schema
        ),
        TRUE
    )
    db$select("SELECT 1");
    client$dropCredentials(credentials$id)
})

test_that("getCredentialsbyId", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    credentials <- client$getCredentials()
    credentials <- client$getCredentialsById(credentials$credentials$id)
    
    # verify credentials structure
    expect_false(is.null(credentials$inUse))
    expect_false(is.null(credentials$credentials))
    expect_false(is.null(credentials$credentials$hostname))
    expect_false(is.null(credentials$credentials$db))
    expect_false(is.null(credentials$credentials$user))
    expect_false(is.null(credentials$credentials$password))
    expect_false(is.null(credentials$credentials$schema))
    expect_false(is.null(credentials$credentials$id))
    
    # verify that the credentials actually work
    credentials = credentials$credentials
    db <- RedshiftDriver$new()
    expect_equal(
        db$connect(
            credentials$host, 
            credentials$db, 
            credentials$user, 
            credentials$password, 
            credentials$schema
        ),
        TRUE
    )
    db$select("SELECT 1");
    client$dropCredentials(credentials$id)
})


test_that("getCredentialsbyIdException", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    expect_that(
        credentials <- client$getCredentialsById(123),
        throws_error()
    )    
})


test_that("killCredentials", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    credentials <- client$getCredentials()$credentials

    # verify that the credentials actually work
    db <- RedshiftDriver$new()
    expect_equal(
        db$connect(
            credentials$host, 
            credentials$db, 
            credentials$user, 
            credentials$password, 
            credentials$schema
        ),
        TRUE
    )

    expect_equal(
        client$killProcesses(credentials$id),
        TRUE
    )
    
    # verify that the connection has been killed
    expect_that(
        db$select("SELECT 1"),
        throws_error()
    )
    client$dropCredentials(credentials$id)
})

test_that("killCredentialsException", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID
    )
    
    expect_that(
        client$killProcess(12345),
        throws_error()
    )
})


test_that("dropCredentialsTransformation", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    credentials <- client$getCredentials()$credentials
    
    # verify that the credentials actually work
    db <- RedshiftDriver$new()
    expect_equal(
        db$connect(
            credentials$host, 
            credentials$db, 
            credentials$user, 
            credentials$password, 
            credentials$schema
        ),
        TRUE
    )
    db$select("SELECT 1")
    
    expect_equal(
        client$dropCredentials(credentials$id),
        TRUE
    )
    
    # verify that the connection has been killed
    expect_that(
        db$select("SELECT 1"),
        throws_error()
    )
})

test_that("dropCredentialsSanbox", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    credentials <- client$getCredentials('sandbox')$credentials
    
    # verify that the credentials actually work
    db <- RedshiftDriver$new()
    expect_equal(
        db$connect(
            credentials$host, 
            credentials$db, 
            credentials$user, 
            credentials$password, 
            credentials$schema
        ),
        TRUE
    )
    db$select("SELECT 1")
    
    expect_equal(
        client$dropCredentials(credentials$id),
        TRUE
    )
    
    # verify that the connection has been killed
    expect_that(
        db$select("SELECT 1"),
        throws_error()
    )
})

test_that("getCredentialsType", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    credentials1 <- client$getCredentials('sandbox')$credentials
    credentials2 <- client$getCredentials('transformations')$credentials
    
    expect_false(credentials1$id == credentials2$id)
    expect_false(credentials1$user == credentials2$user)
    
    # verify that the connection has been killed
    expect_that(
        db$select("SELECT 1"),
        throws_error()
    )
})


test_that("dropCredentialsException", {
    client <- ProvisioningClient$new(
        backend = 'redshift-workspace',
        token = KBC_TOKEN,
        runId = KBC_RUNID,
        url = KBC_APIURL
    )
    
    expect_that(
        client$dropCredentials(12345),
        throws_error()
    )
})
