# this script calculates checks as before, dollars by filtering to TYPE 31, and calcs but doesn't write ITEMS
# Pair with sales.quantile.itmes2.R for items quantile

#this scripts calculates the quantiles for checks, dollars, and items for use in prelim.labor.Rmd and possibly future reports
#it alleviates the need for the calculations (including slow aggregate) to happen during the .Rmd calcs

#sample usage: sales.quantile.prep(annual.sales17, "quants17")

sales.quantile.prep <- function(annual.sales.df, file.name.stem){
  
  library(dplyr)
  library(lubridate)
  
  print("LOADING DATA...")
  dubdig <- function(x) if(nchar(x)==1){paste0(0,x)} else {x} #makes the column double digits
  annual.sales.df$ORDERHOUR <- sapply(annual.sales.df$ORDERHOUR, dubdig)
  annual.sales.df$ORDERMIN <- sapply(annual.sales.df$ORDERMIN, dubdig)
  
  annual.sales.df$Date.Time <- as_datetime(paste0(annual.sales.df$DOB, " ", annual.sales.df$ORDERHOUR,
                                               ":", annual.sales.df$ORDERMIN, ":00"))
  annual.sales.df$Date.Round <- floor_date(annual.sales.df$Date.Time, unit = "hour")
  annual.sales.df$Date <- as_date(annual.sales.df$Date.Time)
  
#check aggregation
  print("AGGREGATING CHECK DATA...")
  annual.agg1 <- aggregate(AMOUNT ~ CHECK + Date.Round + Date, annual.sales.df, sum)
  annual.agg2 <- aggregate(CHECK ~ Date.Round + Date, annual.agg1, length)
  
  annual.agg2$hour <- hour(annual.agg2$Date.Round)
  annual.agg2$weekday <- wday(annual.agg2$Date)
  annual.agg2 <- arrange(annual.agg2, hour)
  checks.agg <- annual.agg2
  
#check quantiles
  print("CALCULATING CHECK QUANTILES")
  
  checks.agg <- arrange(checks.agg, hour)
  
  sales.hours.vec <- checks.agg$hour %>%
    unique()
  #print(hours.vec)
  check.plot.data <- data.frame() # empty data frame to fil up
  
  for(k in 1:7){
    dataset.day <- filter(checks.agg, weekday == k)
    
    for(i in 1:length(sales.hours.vec)){
      sub.i <- filter(dataset.day, hour == sales.hours.vec[i])
      #print(head(sub.i))
      low.i <- quantile(sub.i$CHECK, .125) #switch to "CHECK" if using that
      mean.i <- quantile(sub.i$CHECK, .5)
      high.i <- quantile(sub.i$CHECK, .875)
      sub.i.quant <- cbind(sub.i[1,4:5], low.i, mean.i, high.i)
      #print(sub.i.quant)
      check.plot.data <- rbind(check.plot.data, sub.i.quant)
    }
  }
  check.plot.data <- filter(check.plot.data, !is.na(mean.i))
  
  print("WRITING CHECK DATA...")
  
  write.csv(check.plot.data, paste0("data/", file.name.stem, "checks", Sys.Date(), ".csv"))

# dollars aggregation
  
  print("AGGREGATING DOLLAR DATA...")
  
  annual.sales.df <- filter(annual.sales.df, TYPE == 31)
  
  check.agg <- aggregate(AMOUNT ~ CHECK + DOB, annual.sales.df, sum)
  check.agg$TRANSACTIONID <- row.names(check.agg)
  #print(head(check.agg))
  
  ninetyninth <- quantile(check.agg$AMOUNT, .99)
  #print(paste("ninetyninth is", ninetyninth))
  check.inliers <- filter(check.agg, AMOUNT < ninetyninth)
  #print(paste0("check.agg dim is", dim(check.agg)))
  #print(paste0("check.inliers dim is", dim(check.inliers)))
  #print("check inliers head is")
  #print(head(check.inliers))
  
  #bring the inlier data set together with the original one
  inlier.merge <- merge(annual.sales.df, check.inliers[,-3], by.x = c("CHECK", "DOB"), by.y = c("CHECK", "DOB"), all.x = FALSE, all.y = TRUE)
  
  #print("inlier.merge tail is")
  #print(tail(inlier.merge))
  
  annual.sales.agg.inliers <- aggregate(AMOUNT ~ Date.Round + Date, inlier.merge, sum)
  #print(paste("inliers =", head(annual.sales.agg.inliers)))
  
  annual.sales.agg.inliers$hour <- hour(annual.sales.agg.inliers$Date.Round)
  annual.sales.agg.inliers$weekday <- wday(annual.sales.agg.inliers$Date)
  
  
  dollars.agg <- arrange(annual.sales.agg.inliers, hour)
  
  #dollars quantiles
  
  print("CALCULATING DOLLAR QUANTILES...")
  sales.hours.vec <- dollars.agg$hour %>%
    unique()
  #print(hours.vec)
  dollars.plot.data <- data.frame() # empty data frame to fil up
  
  for(k in 1:7){
    dataset.day <- filter(dollars.agg, weekday == k)
    
    for(i in 1:length(sales.hours.vec)){
      sub.i <- filter(dataset.day, hour == sales.hours.vec[i])
      #print(head(sub.i))
      low.i <- quantile(sub.i$AMOUNT, .125) #switch to "CHECK" if using that
      mean.i <- quantile(sub.i$AMOUNT, .5)
      high.i <- quantile(sub.i$AMOUNT, .875)
      sub.i.quant <- cbind(sub.i[1,4:5], low.i, mean.i, high.i)
      #print(sub.i.quant)
      dollars.plot.data <- rbind(dollars.plot.data, sub.i.quant)
    }
  }
  
  dollars.plot.data <- filter(dollars.plot.data, !is.na(mean.i))
  
  print("WRITING DOLLAR DATA...")
  
  write.csv(dollars.plot.data, paste0("data/", file.name.stem, "dollars",Sys.Date(), ".csv"))
  
  # item aggregation
  
  print("AGGREGATING ITEM DATA...")
  
  item.agg <- aggregate(TYPE ~ Date.Round + Date, annual.sales.df, length)
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
      low.i <- quantile(sub.i$TYPE, .125) #switch to "CHECK" if using that
      mean.i <- quantile(sub.i$TYPE, .5)
      high.i <- quantile(sub.i$TYPE, .875)
      sub.i.quant <- cbind(sub.i[1,4:5], low.i, mean.i, high.i)
      #print(sub.i.quant)
      
      item.plot.data <- rbind(item.plot.data, sub.i.quant)
    }
  }
  item.plot.data <- filter(item.plot.data, !is.na(mean.i))

  print("NOT WRITING ITEM DATA.  USE sales.quantile.items2.R INSTEAD...")
  
  #write.csv(item.plot.data, paste0("data/", file.name.stem, "items2",Sys.Date(), ".csv"))
  
    }