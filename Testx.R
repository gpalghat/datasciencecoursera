library(downloader)
fname <- "housing.csv"
download_if_not_exists(fname, "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv")
DT <- fread(input = fname, sep = ",")

funs <- list(
  fun1 = function() { sapply(split(DT$pwgtp15,DT$SEX),mean) },
  fun2 = function() { tapply(DT$pwgtp15,DT$SEX,mean) },
  fun3 = function() { mean(DT$pwgtp15,by=DT$SEX) },
  fun4 = function() { DT[,mean(pwgtp15),by=SEX] },
  fun5 = function() { rowMeans(DT)[DT$SEX==1]; rowMeans(DT)[DT$SEX==2] },
  fun6 = function() { mean(DT[DT$SEX==1,]$pwgtp15); mean(DT[DT$SEX==2,]$pwgtp15) }
)

## set to FALSE if you want to remove verbose logs below
debug <- TRUE

fastest <- NULL
min <- .Machine$integer.max

lapply(funs, function(FUN) {
  if (debug) print(FUN)
  st <- system.time(x <- try(FUN(), silent = TRUE))
  if (inherits(x, "try-error")) {
    if(debug) print("run-time error, skipping..")  
  } else {
    et <- st[3]
    if (et < min) {
      min <<- et
      fastest <<- FUN
    }
    if (debug) {
      print(paste("elapsed time:", sprintf("%.10f", et)))
      print(x)      
    }
  }
})

## The function 'mean(DT$pwgtp15,by=DT$SEX)' should be the fastest one.
print("The fastest calculation is:")
print(fastest)
msg("with running time of", sprintf("%.10f", min), "seconds")