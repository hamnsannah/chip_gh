
explore_file_cols <- function(obj.from.dims.func){
  require(foreign)
  obj <- obj.from.dims.func

  
  #file.df <- data.frame("file" = 0, "rows" = 0, "cols" = 0)
  for(i in 1:nrow(obj)){
    file.i <- read.dbf(obj$file[i])
    print(paste("i =", i))
    print(obj$file[i])
    print(head(file.i,3))
    print("----------------------------------")
    #i.vec <- c(dbf.files.in.wd[i], nrow(file.i), ncol(file.i))
    #print(i.vec)
    
    #file.df <- rbind(file.df, i.vec)
    #if(w.rows.only == TRUE){
      #file.df <- file.df[file.df$rows >0,]
    #}
  }
  
  #file.df
  
}