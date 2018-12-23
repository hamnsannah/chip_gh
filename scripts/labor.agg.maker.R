# this function takes the excel file of labor minutes for each hour of the day (gndlbsum.csv) and aggregates them for use in week.facet3.R

labor.agg.maker <- function(file.name){
  library(lubridate)
  #setwd("C://Users/The Pritchard family/Documents/R/christophers/")
  labor.data <- read.csv(paste0("data/",file.name), stringsAsFactors = FALSE)
  dubdig <- function(x) if(nchar(x)==1){paste0(0,x)} else {x} #makes specified column double digits
  labor.data$STARTHOUR <- sapply(labor.data$STARTHOUR, dubdig)
  labor.data$Date.Time <- as_datetime(paste0(labor.data$DOB, " ", labor.data$STARTHOUR,
                                             ":00:00"))
  labor.data$Date <- as_date(labor.data$DOB)
  
  jobid.link <- read.csv("data/jobid.link.csv", stringsAsFactors = FALSE) # table with job names linked to IDs
  
  labor.merged <- merge(labor.data, jobid.link, 
                        by.x = "JOBID", by.y = "ID", 
                        all.x = TRUE, all.y = FALSE)
  labor.agg <- aggregate(MINUTES ~ Date.Time + Date + LONGNAME, labor.merged, sum)
  labor.agg$weekday <- wday(labor.agg$Date)
  labor.agg$hour <- hour(labor.agg$Date.Time)
  labor.agg
}