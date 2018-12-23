#### DEPRECATED ###

### use week.facet2.R instead ###

# This script builds the facet plot for each weekday of labor usage

week.facet <- function(dataset, job.or.all = "all", light.color, dark.color){
  
  # needs data set that already has hour (1:24) and weekday (1:7) as columns
  
  library(ggplot2)
  library(dplyr)
  library(lubridate)
  
  hours.vec <- dataset$hour %>%
    unique()
  print(hours.vec)
  hour.plot.data <- data.frame() # empty data frame to fil up
  
  if(job.or.all != "all"){
    dataset <- filter(dataset, LONGNAME == job.or.all)
  }
  
  for(k in 1:7){
    dataset.day <- filter(dataset, weekday == k)
    
  
  for(i in 1:length(hours.vec)){
    sub.i <- filter(dataset.day, hour == hours.vec[i])
    #print(head(sub.i))
    low.i <- quantile(sub.i$MINUTES, .125)
    mean.i <- quantile(sub.i$MINUTES, .5)
    high.i <- quantile(sub.i$MINUTES, .875)
    sub.i.quant <- cbind(sub.i[1, c(3,5,6)], low.i, mean.i, high.i)
    print(sub.i.quant)
    
    # Next steps here
    #1 get these run for each role (choose most important ones)
    #2 get these run for each weekday
    # try facet grid with days horizontal and role vertical or maybe vice versa
    # use light color for 75% and darker version of same color for mean line
    hour.plot.data <- rbind(hour.plot.data, sub.i.quant)
  }
  }
  
  facet.plot <- ggplot(data=hour.plot.data, aes(x=hour)) + 
    geom_ribbon(aes(ymin=(low.i/60), ymax=(high.i/60)), fill = light.color) +
    #geom_ribbon(aes(ymin=(mean.i/60)-.3, ymax=(mean.i/60)+.3), fill = dark.color) +
    geom_line(aes(y= mean.i/60), size = .5, color = dark.color) +
    facet_grid(. ~ weekday) +
    theme_dark()
  facet.plot

}