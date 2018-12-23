
#seems not to be able to import 1 day due to sequence creation

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

gndsale17 <- import.rbind("2017-01-01","2017-12-31", "GNDSALE.DBF")
gndsale16 <- import.rbind("2016-01-01","2016-12-31", "GNDSALE.DBF")

write.csv(gndsale17, "gndsale17.csv")
write.csv(gndsale16, "gndsale16.csv")