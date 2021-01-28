require(shiny)
require(shinydashboard)
require(shinyjs)
require(DT)
require(shinyBS)
require(RPostgres)
require(DBI)
require(dplyr)
require(readr)
require(tibble)

# Global Variables and Functions

# converts checkboxGroupInput output into a comma sep string, useful for capturing in a dataframe and avoiding 'list' type columns
formatListtoCSVString <- function(choices){
  x <- paste(choices,collapse = ", ")
  return(x)
}

# Use a local secrets file to store database information
# Needs to be manually created as I put secrets.R into .gitignore (github)
source("secrets.R",local = TRUE)

# # EXAMPLE secrets.R file contents
# # postgres details
# dbname = "databasename"
# tblname = "tablename"
# host = "Hostname_or_IP"
# port = 5432
# user = "postgres"
# password = "verySecurePassword"
# fields = c("question1")
# 
# # neo4j details
# graph_host <- "http://hostname_or_IP:portnumber"
# graph_user <- "neo4j"
# graph_pass <- "verySecurePassword"

# SAVE AND LOAD DATA FUNCTIONS - Currently a function for CSV and Postgres save/load, neo4j TBD
# https://shiny.rstudio.com/articles/persistent-data-storage.html

# LOCAL CSV
# save data to local csv function

saveDataCSV <- function(data) {
  responses <- readr::read_csv("survey_results/responses.csv",col_types = "ccccccccccccT")# forces column types, all character except last is Datetime
  response <- tibble::tibble(data)
  response <- response %>% dplyr::mutate(added = as.POSIXct(added))# mutate new response added value to Datetime POSIXct, otherwise bind_cols fails
  responses <- dplyr::bind_rows(responses,response)
  readr::write_csv(responses,"survey_results/responses.csv",append = FALSE)
}

loadDataCSV <- function() {
  responses <- readr::read_csv("survey_results/responses.csv",col_types = "ccccccccccccT")# forces column types, all character except last is Datetime
  responses <- responses %>% dplyr::arrange(desc(added))
  responses
}


#POSTGRES DB
# save data to postgres db
saveDataPostgres <- function(data) {
  
  # postgres connection
  
  # Connect to a specific postgres database
  con <- dbConnect(RPostgres::Postgres(),dbname = dbname, 
                   host = host,
                   port = port,
                   user = user,
                   password = password)
  
  db_fields <- dbListFields(con, tblname)
  
  insertQuery <- paste("INSERT INTO ",tblname," (",
                       paste(db_fields,collapse = ", "),
                       ") VALUES ('",
                       paste(as.character(as.vector(data[1,])),collapse = "', '"),
                       "');",
                       sep = "")
  
  safeQuery <- sqlInterpolate(con, insertQuery)
  
  res <- dbSendQuery(con, safeQuery)
  dbClearResult(res)
  dbDisconnect(con)
  
}

loadDataPostgres <- function() {
  
  con <- dbConnect(RPostgres::Postgres(),dbname = dbname, 
                   host = host,
                   port = port,
                   user = user,
                   password = password)
  
  # use this line in place of the following line if you want to reduce the number of columns displayed in the results view
  # create a string object called fields with comma separated columns to display
  # e.g. fields = "question1, question2, summary1, optionsList, start_date, end_date, added"
  #res <- dbSendQuery(con, paste("SELECT ",fields," FROM ",tblname,";",sep = ""))
  
  res <- dbSendQuery(con, paste("SELECT * FROM ",tblname,";",sep = ""))
  result <- dbFetch(res)
  # optional step, make the column names prettier by renaming from those pulled from postgres
  # NOTE: depends upon fields selected above! Must be the same length
  #newNames = c("Question 1","Question 2","Summary","Options","Start Date","End Date","Date Added")
  #names(result) <- newNames
  dbClearResult(res)
  dbDisconnect(con)
  return(result)
  
}