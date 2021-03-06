#' Extract identifying variables
#'
#' This function extracts the identifying variables from a table by applying a
#' schema description to it.
#' @param schema [\code{character(1)}]\cr the schema description of
#'   \code{input}.
#' @param input [\code{character(1)}]\cr table to reorganise.
#' @return list of the length of number of clusters with values of the
#'   identifying variables per cluster
#' @examples
#' input <- tabs2shift$clusters_nested
#' schema <- setCluster(id = "sublevel",
#'                      group = "territories", member = c(1, 1, 2),
#'                      left = 1, top = c(3, 8, 15)) %>%
#'   setIDVar(name = "territories", columns = 1, rows = c(2, 14)) %>%
#'   setIDVar(name = "sublevel", columns = 1, rows = c(3, 8, 15)) %>%
#'   setIDVar(name = "year", columns = 7) %>%
#'   setIDVar(name = "commodities", columns = 2) %>%
#'   setObsVar(name = "harvested", columns = 5) %>%
#'   setObsVar(name = "production", columns = 6)
#'
#' validateSchema(schema = schema, input = input) %>%
#'    getIDVars(input = input)
#' @importFrom purrr map set_names
#' @importFrom dplyr row_number
#' @importFrom tidyr extract unite
#' @export

getIDVars <- function(schema = NULL, input = NULL){

  clusters <- schema@clusters
  nClusters <- max(lengths(clusters))

  variables <- schema@variables
  filter <- schema@filter

  idVars <- map(.x = seq_along(variables), .f = function(ix){
    # unselect those id variables that are also cluster id or group
    if(variables[[ix]]$type == "id" & !names(variables)[ix] %in% c(clusters$id, clusters$group)){
      variables[ix]
    }
  })
  idVars <- unlist(idVars, recursive = FALSE)

  # if there are listed observed variables, act as if they were clusters
  filterRows <- map(.x = seq_along(variables), .f = function(ix){
    theVar <- variables[[ix]]
    if(theVar$type == "observed"){
      if(is.numeric(theVar$key)){
        which(input[[theVar$key]] %in% theVar$value)
      }
    }
  })
  if(any(lengths(filterRows) != 0)){
    listedObs <- TRUE
    filterRows <- filterRows[lengths(filterRows) != 0]
    nClusters <- length(filterRows)
  } else {
    listedObs <- FALSE
  }

  if(length(idVars) != 0){

    out <- map(.x = 1:nClusters, .f = function(ix){
      vars <- NULL
      for(i in 1:length(idVars)){

        tempVar <- idVars[[i]]
        if(listedObs){
          if(!is.null(tempVar$row)){
            tempVar$row <- rep(x = tempVar$row, length.out = nClusters)
          } else {
            tempVar$col <- rep(x = tempVar$col, length.out = nClusters)
          }
          clusterRows <- filterRows[[ix]]
        } else {
          clusterRows <- clusters$row[ix]:(clusters$row[ix]+clusters$height[ix] - 1)
        }

        if(!is.null(tempVar$value)){
          temp <- tibble(X = tempVar$value)
        } else {

          if(!is.null(tempVar$row[ix])){
            if(!tempVar$dist){
              # in case a row value is set, this means we deal with a variable that is not tidy ...
              temp <- input[tempVar$row[ix], tempVar$col]
              theFilter <- NULL
            } else {
              # ... or distinct from clusters
              temp <- input[unique(tempVar$row), unique(tempVar$col)]
              theFilter <- NULL
            }
          } else {

            if(!is.null(tempVar$merge)){
              temp <- input[clusterRows, tempVar$col]
              theFilter <- filter$row
            } else {
              temp <- input[clusterRows, tempVar$col[ix]]
              theFilter <- which(clusterRows %in% filter$row)
            }

          }

          if(!is.null(tempVar$split)){
            temp <- temp %>%
              extract(col = 1, into = names(temp), regex = paste0("(", tempVar$split, ")"))
          }
          if(!is.null(tempVar$merge)){
            newName <- paste0(names(temp), collapse = tempVar$merge)
            temp <- temp %>%
              unite(col = !!newName, sep = tempVar$merge)
          }

          if(!is.null(theFilter)){
            temp <- temp %>%
              filter(!row_number() %in% theFilter)
          }
        }

        vars <- c(vars, set_names(x = list(temp), nm = names(idVars)[i]))

      }
      return(vars)

    })



  } else {
    out <- NULL
  }

  return(out)

}