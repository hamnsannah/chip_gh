---
title: "Dollar Check (Scratch)"
author: "Allocate Analytics"
date: "September 3, 2018"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

library(foreign)
library(dplyr)
library(lubridate)
library(knitr)

import.rbind <- function(start.date, end.date, file.name){
  wd <- getwd()
  setwd("C://Users/The Pritchard family/Downloads/Aloha-Data-ALL/")
  library(foreign)
  start.date <- as.Date(start.date)
  end.date <- as.Date(end.date)
  date.vec <- seq.Date(start.date,end.date, by = "day")
  file.vec <- gsub("-", "", date.vec)
  fpath.prelim <- paste0(file.vec[1], "/", file.name)
  imported.prelim <- read.dbf(fpath.prelim)
  
  agg.files <- imported.prelim
  for(i in 2:length(file.vec)){
    print(file.vec[i])
    fpath <- paste0(file.vec[i], "/", file.name)
    imported.i <- read.dbf(fpath)
    agg.files <- rbind(agg.files, imported.i)
  }
  print(head(agg.files))
  print(dim(agg.files))
    #print(file.vec)
setwd(wd)
agg.files
}

sales.data <- import.rbind("2017-06-05", "2017-06-06", "GNDSALE.DBF")

```



```{r, echo=FALSE}
head(sales.data)



```

