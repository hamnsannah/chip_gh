
explore_file_dims <- function(w.rows.only = FALSE){
  require(foreign)
  dbf.files.in.wd <- list.files(pattern = "\\.dbf", ignore.case = TRUE)
  dbf.files.in.wd <- dbf.files.in.wd[-34] #removes file with no fields

  file.df <- data.frame("file" = 0, "rows" = 0, "cols" = 0)
  for(i in 1:length(dbf.files.in.wd)){
    file.i <- read.dbf(dbf.files.in.wd[i])
    i.vec <- c(dbf.files.in.wd[i], nrow(file.i), ncol(file.i))
  #print(i.vec)

  file.df <- rbind(file.df, i.vec)
  if(w.rows.only == TRUE){
    file.df <- file.df[file.df$rows >0,]
  }
  }

  file.df

}