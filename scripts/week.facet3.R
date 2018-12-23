# this script can plot all job types, with or without sales overlaid.
# if template-izing better to match dual axis using mean of data set rather than max
# built on 2016 data

#dataset is labor.agg which can be generated with labor.agg.maker.R

# double plotting works

#sample usage: week.facet(dataset= labor.agg, job.or.all = "SERVER", light.color = "light blue", dark.color = "dark blue", compare.sales = TRUE)
#

week.facet <- function(dataset, job.or.all = "all", light.color, dark.color, 
                       compare.sales = FALSE, dollars.checks.items = "checks"){
  # needs data set that already has hour (1:24) and weekday (1:7) as columns
  
  library(ggplot2)
  library(dplyr)
  library(lubridate)
  
  hours.vec <- dataset$hour %>%
    unique()
  #print(hours.vec)
  
  hour.plot.data <- data.frame() # empty data frame to fil up
  
  if(job.or.all != "all"){
    dataset <- filter(dataset, LONGNAME == job.or.all)
  } else{ # this aggregates the minutes for all the job types, then adds the dropped column back in
    dataset <- aggregate(MINUTES ~ Date.Time + Date + weekday + hour, dataset, sum)
    dataset$LONGNAME <- "all"
    dataset <- select(dataset, c(1,2,6,5,3,4))
  }
  
  for(k in 1:7){
    dataset.day <- filter(dataset, weekday == k)
    
    for(i in 1:length(hours.vec)){
      sub.i <- filter(dataset.day, hour == hours.vec[i])
      #print(head(sub.i, 2))
      low.i <- quantile(sub.i$MINUTES, .125)
      mean.i <- quantile(sub.i$MINUTES, .5)
      high.i <- quantile(sub.i$MINUTES, .875)
      sub.i.quant <- cbind(sub.i[1, c(3,5,6)], low.i, mean.i, high.i)
      #print(sub.i.quant)
      
      hour.plot.data <- rbind(hour.plot.data, sub.i.quant)
    }
  }
  
  hour.plot.data <- hour.plot.data %>% 
    filter(!is.na(weekday), weekday != 1) %>%
    arrange(weekday)
  days.df <- data.frame("weekday" = 1:7, "day" = c("Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"))
  days.df$day <- factor(days.df$day, levels = c("Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"))
hour.plot.data <- merge(hour.plot.data, days.df, all.x = TRUE, all.y = FALSE)  

  if(compare.sales == TRUE){
    
    calibration.coef <- max(hour.plot.data$mean.i, na.rm = TRUE)/60 ### I calibrated sales (green) to sales, so this scales others to that (for 2016 at least)
    
    if(dollars.checks.items == "checks"){
      sales.quartiles <- read.csv("data/sales.quartiles.16.csv", stringsAsFactors = FALSE)
      scale.ratio <- (48/calibration.coef) ### this parameter scales the sales data to be co-plotted with labor data, but it's different for each type
    } else if(dollars.checks.items == "dollars"){
      sales.quartiles <- read.csv("data/sales.inliers.quartiles.16.csv", stringsAsFactors = FALSE)
      scale.ratio <- 7200/calibration.coef # CHANGE FOR DOLLARS
    } else if(dollars.checks.items == "items"){
      sales.quartiles <- read.csv("data/sales.item.quartiles.16.csv", stringsAsFactors = FALSE)
      scale.ratio <- 810/calibration.coef #### CHANGE FOR ITEMS
    }
    #sales.quartiles <- read.csv("data/sales.quartiles.16.csv", stringsAsFactors = FALSE)
    sales.quartiles <- filter(sales.quartiles, !is.na(weekday), weekday != 1)
    
    sales.quartiles <- merge(sales.quartiles, days.df, all.x = TRUE, all.y = FALSE)
    
    #print(tail(sales.quartiles, 100))
    #print(class(sales.quartiles))
    
    #print(str(hour.plot.data))
    #print(head(dataset))
    #print(head(hour.plot.data))
  
    facet.plot <- ggplot(data = hour.plot.data, aes(x=hour)) +
      geom_ribbon(data = sales.quartiles, aes(ymin=(low.i/scale.ratio), ymax=(high.i/scale.ratio)), fill = "light green", alpha = .35) +
      geom_line(data = sales.quartiles, aes(y= mean.i/scale.ratio), size = 1, color = "green") +
      
      geom_ribbon(data = hour.plot.data, aes(ymin=(low.i/60), ymax=(high.i/60)), fill = light.color, alpha = 0.35) +
      geom_line(data = hour.plot.data, aes(y= mean.i/60), size = 1, color = dark.color) +
      
      #geom_ribbon(data = hour.plot.data, aes(ymin=(mean.i/60)-.3, ymax=(mean.i/60)+.3), fill = dark.color) +
      #geom_ribbon(aes(ymin=(mean.i/60)-.3, ymax=(mean.i/60)+.3), fill = dark.color) +

      facet_grid(. ~ day) +
      
      scale_y_continuous(sec.axis = sec_axis(~.*scale.ratio, name = paste0("Volume by ", dollars.checks.items)), limits = c(0, NA)) +
      
      labs(y= "Num. of Employees", x = "Hour of the Day") +
      ggtitle(label = "Comparison of Sales vs Labor", 
                subtitle = paste0("Sales based on ", dollars.checks.items, 
                                  " and labor for job type ", job.or.all))+
      scale_x_continuous(breaks = c(6,12,18,24), labels = c("6am", "12pm", "6pm", "12am" ))+
      theme_dark()
  } else {
    facet.plot <- ggplot(data=hour.plot.data, aes(x=hour)) +
      geom_ribbon(aes(ymin=(low.i/60), ymax=(high.i/60)), fill = light.color, alpha = .5) +
      geom_line(aes(y= mean.i/60), size = .5, color = dark.color) +
      facet_grid(. ~ day) +
      labs(y= "Num. of Employees", x = "Hour of the Day") +
      ggtitle(label = "Hourly Labor Usage Throughout Week", 
              subtitle = paste0("Hours shown for job type: ", job.or.all))+
      scale_x_continuous(breaks = c(6,12,18,24), labels = c("6am", "12pm", "6pm", "12am" ))+
      theme_dark()
  }
  #print(max(hour.plot.data$mean.i, na.rm = TRUE)/60)

  facet.plot
}