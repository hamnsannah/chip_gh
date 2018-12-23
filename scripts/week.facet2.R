######## REPLACED BY week.facet3.R #########

# double plotting works
# need to be able to show with sales minus outliers
# is it best to have an option with just lines rather than using ribbon too? I think so
# need to format axis in 4s rather than 5s and add titles and axes & second axis
# remove NAs from dataset

week.facet <- function(dataset, job.or.all = "all", light.color, dark.color, compare.sales = FALSE){
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
      print(head(sub.i, 2))
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

  if(compare.sales == TRUE){
    sales.quartiles <- read.csv("data/sales.quartiles.16.csv", stringsAsFactors = FALSE)
    print(tail(sales.quartiles, 100))
    print(class(sales.quartiles))
    
    facet.plot <- ggplot(data = hour.plot.data, aes(x=hour)) +
      geom_ribbon(data = sales.quartiles, aes(ymin=(low.i/8), ymax=(high.i/8)), fill = "light green") +
      geom_line(data = sales.quartiles, aes(y= mean.i/8), size = 1, color = "dark green") +
      
      geom_ribbon(data = hour.plot.data, aes(ymin=(low.i/60), ymax=(high.i/60)), fill = light.color) +
      #geom_ribbon(data = hour.plot.data, aes(ymin=(mean.i/60)-.3, ymax=(mean.i/60)+.3), fill = dark.color) +
      

      #geom_ribbon(aes(ymin=(mean.i/60)-.3, ymax=(mean.i/60)+.3), fill = dark.color) +
      geom_line(data = hour.plot.data, aes(y= mean.i/60), size = 1, color = dark.color) +
      facet_grid(. ~ weekday) +
      theme_dark()
    } else {
      facet.plot <- ggplot(data=hour.plot.data, aes(x=hour)) +
        geom_ribbon(aes(ymin=(low.i/60), ymax=(high.i/60)), fill = light.color) +
        #geom_ribbon(aes(ymin=(mean.i/60)-.3, ymax=(mean.i/60)+.3), fill = dark.color) +
        geom_line(aes(y= mean.i/60), size = .5, color = dark.color) +
        facet_grid(. ~ weekday) +
        theme_dark()
    }
  facet.plot
  }
# can't just use two datasets I believe.  Need to merge or join.
# check how I did the target school graph with public and private
