
#' Client for working with Keboola Connection Provisioning API.
#' 
#' The client allows to create and retrieve credentials for sandbox and
#' transformation buckets. Additional methods to kill sandbox/transformation 
#' bucket are available.
#' @import httr methods
#' @export ProvisioningClient
#' @exportClass ProvisioningClient
ProvisioningClient <- setRefClass(
    'ProvisioningClient',
    fields = list(
        backend = 'character', 
        token = 'character', 
        runId = 'character', 
        url = 'character'
    ),
    methods = list(
        initialize = function(backend, token, runId = '', url = 'https://syrup.keboola.com/provisioning') {
            "Constructor.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{backend} Type of database backend - either \\code{snowflake} or \\code{redshift-workspace}}
            \\item{\\code{token} KBC Storage API token.}
            \\item{\\code{runId} Optional Run ID of the parent job.}
            \\item{\\code{url} Optional URL of the provisioning API.}
            }}"
            backend <<- backend
            token <<- token
            runId <<- runId
            url <<- url
        },
        
        decodeResponse = function(response) {
            "Internal method to process API response.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{response} List as returned from \\code{httr} POST/GET methods.}
            }}
            \\subsection{Return Value}{Response body - either list or string in case the body cannot be parsed as JSON.}"
            content <- content(response, as = "text", encoding = 'utf-8')
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

        getCredentials = function(type = "transformations") {
            "Get new credentials of the given type or reuse existing credentials if available.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{type} Credentials type - either \\code{transformations} or \\code{sandbox}}
            }}
            \\subsection{Return Value}{List with credentials.}"
            response <- POST(
                paste0(url, '/', backend), 
                add_headers('X-StorageAPI-Token' = token),
                body = list(type = type),
                encode = "json"
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
        
        getCredentialsById = function(id) {
            "Get existing credentials.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{id} Credentials id.}
            }}
            \\subsection{Return Value}{List with credentials.}"
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
        
        dropCredentials = function(id) {
            "Delete credentials and cleanup the associated database bucket.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{id} Credentials id.}
            }}
            \\subsection{Return Value}{TRUE}"
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
        
        killProcesses = function(id) {
            "Kill database processes running with the given credentials.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{id} Credentials id.}
            }}
            \\subsection{Return Value}{TRUE}"
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
