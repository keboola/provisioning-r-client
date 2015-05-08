
#' Client for working with Keboola Connection Provisioning API.
#' 
#' The client allows to create and retrieve credentials for sandbox and
#' transformation buckets. Additional methods to kill sandbox/transformation 
#' bucket are available.
#' @import httr methods
#' @exportClass ProvisioningClient
#' @export ProvisioningClient
ProvisioningClient <- setRefClass(
    'ProvisioningClient',
    fields = list(
        backend = 'character', 
        token = 'character', 
        runId = 'character', 
        url = 'character'
    ),
    methods = list(
        #' Constructor.
        #'
        #' @param backend Type of database backend - either 'mysql' or 'redshift'.
        #' @param token KBC Storage API token.
        #' @param runId Optional ID of the parent run.
        #' @param url Optional URL of the provisioning API.
        #' @exportMethod
        initialize = function(backend, token, runId = '', url = 'https://syrup.keboola.com/provisioning') {
            backend <<- backend
            token <<- token
            runId <<- runId
            url <<- url
        },
        
        #' Internal method to process API response
        #' @param response List as returned from httr POST/GET method
        #' @return response body - either list or string in case the body cannot be parsed as JSON.
        decodeResponse = function(response) {
            # decode response
            content <- content(response, as = "text")
            body <- NULL
            tryCatch({
                body <- jsonlite::fromJSON(content)
            }, error = function (e) {                
            })
            if (is.null(body)) {
                # failed to parse body as JSON
                body <- content
            }
            
            # handle errors 
            if (!(response$status_code %in% c(200, 201))) {
                if ((class(body) == 'list') && !is.null(body$message)) {
                    stop(paste0("Error recieving response from provisioning API: ", body$message))
                } else if (class(body) == 'list') {
                    str <- print(body)
                    stop(paste0("Error recieving response from provisioning API: ", str))
                } else if (class(body) == 'character') {
                    stop(paste0("Error recieving response from provisioning API: ", body))
                } else {
                    stop(paste0("Error recieving response from provisioning API: unknown reason."))
                }
            }
            body            
        },
        
        #' Get new credentials of the given type or reuse existing credentials if available.
        #' 
        #' @param type Credentials type - either 'transformations' or 'sandbox'
        #' @return list with credentials
        #' @exportMethod
        getCredentials = function(type = "transformations") {
            response <- POST(
                paste0(url, '/', backend), 
                add_headers('X-StorageAPI-Token' = token),
                query = list(type = type)
            )
            
            body <- decodeResponse(response)
            # check response 
            if ((class(body) != 'list') || is.null(body$credentials)) {
                str <- print(body)
                stop(paste0("Malformed response from provisioning API: ", str))
            }
            
            # response is valid
            body
        },
        
        #' Get existing credentials.
        #' 
        #' @param id Credentials id.
        #' @return list with credentials
        #' @exportMethod
        getCredentialsById = function(id) {
            if (is.null(id)) {
                stop("Id must be entered")
            }            
            response <- GET(
                paste0(url, '/', backend, '/', id), 
                add_headers('X-StorageAPI-Token' = token)
            )
            
            body <- decodeResponse(response)
            # check response 
            if ((class(body) != 'list') || is.null(body$credentials)) {
                str <- print(body)
                stop(paste0("Malformed response from provisioning API: ", str))
            }
            
            # response is valid
            body        
        },
        
        #' Delete credentials and cleanup the associated database bucket.
        #' 
        #' @param id Credentials id.
        #' @return TRUE
        #' @exportMethod
        dropCredentials = function(id) {
            if (is.null(id)) {
                stop("Id must be entered")
            }
            response <- DELETE(
                paste0(url, '/', backend, '/', id), 
                add_headers('X-StorageAPI-Token' = token)
            )
            
            body <- decodeResponse(response)
            # check response 
            if ((class(body) != 'list') || is.null(body$status)) {
                str <- print(body)
                stop(paste0("Malformed response from provisioning API: ", str))
            }
            
            # response is valid
            TRUE
        },
        
        #' Kill database processes running with the given credentials
        #' 
        #' @param id Credentials id.
        #' @return TRUE
        #' @exportMethod
        killProcesses = function(id) {
            if (is.null(id)) {
                stop("Id must be entered")
            }            
            response <- POST(                
                paste0(url, '/', backend, '/', id, '/', 'kill'), 
                add_headers('X-StorageAPI-Token' = token)
            )
            
            body <- decodeResponse(response)
            # check response 
            if ((class(body) != 'list') || is.null(body$status)) {
                str <- print(body)
                stop(paste0("Malformed response from provisioning API: ", str))
            }
            
            # response is valid
            TRUE
        }
    )    
)
