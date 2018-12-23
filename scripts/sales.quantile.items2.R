
# after new info from Jerry, realized I need to compute item quantiles differently using GNDITEM.DBF instead of GNDSALE.
# This accomplishes that.  But still needs QAing because this is partially just a copy paste from the console.

sales.quantile.items2 <- function(item.df, file.name.stem){

library(dplyr)
library(lubridate)

print("LOADING DATA...")
dubdig <- function(x) if(nchar(x)==1){paste0(0,x)} else {x} #makes the column double digits
item.df$HOUR <- sapply(item.df$HOUR, dubdig)
item.df$MINUTE <- sapply(item.df$MINUTE, dubdig)

item.df$Date.Time <- as_datetime(paste0(item.df$DOB, " ", item.df$HOUR,
                                                ":", item.df$MINUTE, ":00"))
item.df$Date.Round <- floor_date(item.df$Date.Time, unit = "hour")
item.df$Date <- as_date(item.df$Date.Time)

print("AGGREGATING ITEM DATA...")

item.agg <- aggregate(ENTRYID ~ Date.Round + Date, item.df, length)
item.agg$hour <- hour(item.agg$Date.Round)
item.agg$weekday <- wday(item.agg$Date)
item.agg <- arrange(item.agg, hour)

# item quantiles

print("CALCULATING ITEM QUANTILES...")

item.agg <- arrange(item.agg, hour)

sales.hours.vec <- item.agg$hour %>%
  unique()
#print(hours.vec)
item.plot.data <- data.frame() # empty data frame to fil up

for(k in 1:7){
  dataset.day <- filter(item.agg, weekday == k)
  
  for(i in 1:length(sales.hours.vec)){
    sub.i <- filter(dataset.day, hour == sales.hours.vec[i])
    #print(head(sub.i))
    low.i <- quantile(sub.i$ENTRYID, .125) #switch to "CHECK" if using that
    mean.i <- quantile(sub.i$ENTRYID, .5)
    high.i <- quantile(sub.i$ENTRYID, .875)
    sub.i.quant <- cbind(sub.i[1,4:5], low.i, mean.i, high.i)
    #print(sub.i.quant)
    
    item.plot.data <- rbind(item.plot.data, sub.i.quant)
  }
}
item.plot.data <- filter(item.plot.data, !is.na(mean.i))

print("WRITING ITEM DATA...")

write.csv(item.plot.data, paste0("data/", file.name.stem, "items.file",Sys.Date(), ".csv"))

}
