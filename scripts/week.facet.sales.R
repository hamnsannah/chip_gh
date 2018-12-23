# preliminary steps to prepare dataset 
######## this is mainly just the steps taken more than a script #########

require(dplyr)
require(ggplot2)
require(sugrrants)
require(lubridate)
require(knitr)
annual.sales <- read.csv("data/gndsale16.csv", stringsAsFactors = FALSE)

dubdig <- function(x) if(nchar(x)==1){paste0(0,x)} else {x} #makes the column double digits
annual.sales$ORDERHOUR <- sapply(annual.sales$ORDERHOUR, dubdig)
require(scales)
require(gridExtra)

annual.sales$ORDERMIN <- sapply(annual.sales$ORDERMIN, dubdig)

annual.sales$Date.Time <- as_datetime(paste0(annual.sales$DOB, " ", annual.sales$ORDERHOUR,
                                             ":", annual.sales$ORDERMIN, ":00"))
#<- as_datetime(annual.sales$DOB)

annual.sales$Date.Round <- floor_date(annual.sales$Date.Time, unit = "hour")
annual.sales$Date <- as_date(annual.sales$Date.Time)

annual.agg1 <- aggregate(AMOUNT ~ CHECK + Date.Round + Date, annual.sales, sum)
annual.agg2 <- aggregate(CHECK ~ Date.Round + Date, annual.agg1, length)

annual.agg2$hour <- hour(annual.agg2$Date.Round)
annual.agg2$weekday <- wday(annual.agg2$Date)
annual.agg2 <- arrange(annual.agg2, hour)
dataset <- annual.agg2

######### Here's the function

week.facet.sales <- function(dataset, light.color, dark.color){
  
  # This script builds the facet plot for each weekday of sales but was actually only used in pieces in the console
  
    # needs data set that already has hour (1:24) and weekday (1:7) as columns
    
    library(ggplot2)
    library(dplyr)
    library(lubridate)
    
  dataset <- arrange(dataset, hour)
  
    sales.hours.vec <- dataset$hour %>%
      unique()
    print(hours.vec)
    hour.plot.data <- data.frame() # empty data frame to fil up
    
    for(k in 1:7){
      dataset.day <- filter(dataset, weekday == k)
      
      
      for(i in 1:length(sales.hours.vec)){
        sub.i <- filter(dataset.day, hour == sales.hours.vec[i])
        #print(head(sub.i))
        low.i <- quantile(sub.i$AMOUNT, .125) #switch to "CHECK" if using that
        mean.i <- quantile(sub.i$AMOUNT, .5)
        high.i <- quantile(sub.i$AMOUNT, .875)
        sub.i.quant <- cbind(sub.i[1,4:5], low.i, mean.i, high.i)
        print(sub.i.quant)
        
        # Next steps here
        #1 get these run for each role (choose most important ones)
        #2 get these run for each weekday
        # try facet grid with days horizontal and role vertical or maybe vice versa
        # use light color for 75% and darker version of same color for mean line
        hour.plot.data <- rbind(hour.plot.data, sub.i.quant)
      }
    }
    
    sales.facet.plot <- ggplot(data=hour.plot.data, aes(x=hour)) + 
      geom_ribbon(aes(ymin=(low.i), ymax=(high.i)), fill = light.color) +
      #geom_ribbon(aes(ymin=(mean.i/60)-.3, ymax=(mean.i/60)+.3), fill = dark.color) +
      geom_line(aes(y= mean.i), size = 1, color = dark.color) +
      facet_grid(. ~ weekday) +
      theme_dark()
    sales.facet.plot
    
  }