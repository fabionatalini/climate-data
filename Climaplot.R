##############################################################################################################
### Hi! This is Climaplot, a program that will enable you to plot a climograph with your own climate data. ###
### Author: Fabio Natalini.                                                                                ###
### A user manual is available in my github repository (https://github.com/fabionatalini/climate-data).    ###
### To know more, visit my website and blog (https://fabionatalini.wixsite.com/fabio).                     ###
### Any question, comment or suggestion? Contact me: https://fabionatalini.wixsite.com/fabio/contact       ###
##############################################################################################################


######################################## User inputs ###########################################

# working directory
cat("Enter the working directory:")
foo <- 0
while (foo<1) {
  item <- readLines(con="stdin", n=1)
  item <- as.character(item)
  if (nchar(item)>0 & dir.exists(item)) {
    setwd(item)
    foo <- foo+1
  }
  if (nchar(item)==0 | !dir.exists(item)) {
    cat("The entered directory does not exist, or no directory was entered. Please enter the working directory:")
  }
}
cat(paste("The working directory is:", item, "\n"))

# climate data set
cat("Enter the name of the climate data set (include extension, e.g. 'my_data.txt'):")
foo <- 0
while (foo<1) {
  item <- readLines(con="stdin", n=1)
  item <- as.character(item)
  if (nchar(item)>0 & file.exists(file.path(getwd(),item))) {
    dclima<-read.table(item, header=TRUE, sep='\t', na.strings="", stringsAsFactors=FALSE)
    foo <- foo+1
  }
  if (nchar(item)==0 | !file.exists(file.path(getwd(),item))) {
    cat("This file does not exist, or no file name was entered. Please enter the name of the climate data set:")
  }
}
cat(paste("The climate data set is:", item, "\n"))

# site of climate data
cat("Enter the name of the site of the climate data:")
foo <- 0
while (foo<1) {
  item <- readLines(con="stdin", n=1)
  item <- as.character(item)
  if (nchar(item)>0) {
    your_site<-item
    foo <- foo+1
  }
  if (nchar(item)==0) {
    cat("No name was entered. Please enter the name of the site of the climate data:")
  }
}
cat(paste("The site of the climate data is:", item, "\n"))

# Enter the name of the output file
cat("Enter the name of your output image file:")
foo <- 0
while (foo<1) {
  item <- readLines(con="stdin", n=1)
  item <- as.character(item)
  if (nchar(item)>0) {
    output_file_name<-item
    foo <- foo+1
  }
  if (nchar(item)==0) {
    cat("No name was entered. Please enter the name of your output image file:")
  }
}
cat(paste("The name of your output image file will be:", item, "\n"))

# Format of the output image file (jpeg, png, tiff, pdf)
cat("Enter the format of your output image file (it can be jpeg, png, tiff or pdf): ")
foo <- 0
while (foo<1) {
  item <- readLines(con="stdin", n=1)
  item <- as.character(item)
  if (nchar(item)>0 & length(intersect(item,c('jpeg', 'png', 'tiff', 'pdf')))>0) {
    output_file_format<-item
    foo <- foo+1
  }
  if (nchar(item)==0 | length(intersect(item,c('jpeg', 'png', 'tiff', 'pdf')))==0) {
    cat("No format was entered, or the entered format is not valid. Please choose jpeg, png, tiff or pdf as format of your output image file:")
  }
}
cat(paste("The format of your output image file will be:", item, "\n"))


################################### check, format and order of dates ##########################################

cat("....................................................................................................\n")
cat(".............. Reading the dataset. The date format will be assumed as YYYY-MM-DD ..................\n")
cat("... Please note that your dataset will be chronologically ordered according to the column 'date' ...\n")
cat("....................................................................................................\n")

# Suspend execution for 5 seconds
Sys.sleep(5)

# Check the number and the names of the columns:
# if there are three columns, and their names are OK, go on. If there are five columns, make a new column named "date".
if (ncol(dclima)==3) {
  cat("Your dataset has three columns.\n")
  if (paste(as.character(names(dclima)==c("date","mean_temp","precip")), collapse = "") == "TRUETRUETRUE") {
    cat("The names of the columns of your datset are 'date', 'mean_temp' and 'precip'. OK!\n")
    dclima <- dclima
  } else {stop("The names of the columns of your datset are not 'date', 'mean_temp' and 'precip'. Please set the names.")}
} else if (ncol(dclima)==5) {
  cat("Your dataset has five columns.\n")
  if (paste(as.character(names(dclima)==c("year","month","day","mean_temp","precip")), collapse = "") == "TRUETRUETRUETRUETRUE") {
    cat("The names of the columns of your datset are 'year','month','day','mean_temp','precip'. OK!\n")
    dclima$month_new <- ifelse(nchar(dclima$month)<2, paste0("0", dclima$month), dclima$month)
    dclima$day_new <- ifelse(nchar(dclima$day)<2, paste0("0", dclima$day), dclima$day)
    dclima$date <- paste0(dclima$year,"-",dclima$month_new,"-",dclima$day_new)
    dclima <- dclima[, c("date", "mean_temp", "precip")]
    # The presence of NA would give a warning message: suppress the warning messages
    dclima$mean_temp <- suppressWarnings(as.numeric(dclima$mean_temp))
    dclima$precip <- suppressWarnings(as.numeric(dclima$precip))
  } else {stop("The names of the columns of your datset are not 'year','month','day','mean_temp','precip'. Please set the names.")}
} else {stop("The number of columns of your dataset must be 3 or 5. Please check your dataset.")}

# reset the row names (if any)
row.names(dclima) <- NULL

# checking for missing dates
if (anyNA(dclima$date)) {
  stop("There are blank cells in the column 'date' of your dataset. Please provide data without blank cells in the column 'date'.")
}

# check if the year is a string of 4 digits, and the month and day are strings of 2 digits
if (!all(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", dclima$date))) {
  cat("The following dates or your dataset have not the format YYYY-MM-DD")
  cat(dclima$date[!grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", dclima$date)])
  cat("These dates are in the following lines of the dataset:")
  cat(row.names(dclima[!grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", dclima$date),]))
  stop("Please check the date format of your dataset.")
}

# set date format
dclima$date <- as.Date(dclima$date, "%Y-%m-%d")

# check for wrongly written dates
if (anyNA(dclima$date)) {
  cat("The values in the following lines of 'date' column are not dates:")
  cat(row.names(dclima[is.na(dclima$date),]))
  stop("Please check the date format of your dataset.")
}

# order the dataset by date in descending order
dclima <- dclima[order(dclima$date),]


################################### Check for wrong or missing dates ##########################################

# if any wrong or missing date is found, the program will stop and inform about wrong or missing dates

cat("..........................................................................\n")
cat("..... Checking for repeated, missing or wrong dates in your dataset ......\n")
cat(".... A complete sequence of dates will be created to check your dates ....\n")
cat("..........................................................................\n")

# Suspend execution for 5 seconds
Sys.sleep(5)

# check for duplicated dates
if (length(dclima$date[duplicated(dclima$date)])>0) {
  cat("The following dates are duplicated in your dataset:")
  cat(dclima$date[duplicated(dclima$date)])
  stop("Please check dates in your dataset.")
}

# create an object with a sequence of dates
temp<-seq(min(dclima$date),max(dclima$date),'days')

if (!identical(temp, dclima$date)) {
  cat("The following dates in the complete sequence are not matched in your data:")
  cat(setdiff(as.character(temp), as.character(dclima$date)))
  stop("Please check dates in your dataset.")
}

rm(temp)


################################### Keep only complete years ##########################################

cat("................................................................................\n")
cat("........................... Checking for complete years ........................\n")
cat("......... The oldest and most recent dates of your dataset will be checked .....\n")
cat("... Only data of complete years (from January 1 to December 31) will be used ...\n")
cat("................................................................................\n")

# Suspend execution for 5 seconds
Sys.sleep(5)

# add columns
dclima$year <- as.integer(substr(dclima$date, 1, 4))
dclima$month <- as.integer(substr(dclima$date, 6, 7))
dclima$day <- as.integer(substr(dclima$date, 9, 10))

# check if the last date is before 31 of December
if (tail(dclima, 1)[,"month"] < 12) {
  dclima <- dclima[dclima$year != as.integer(substr(tail(dclima, 1)[,"date"], 1, 4)),]
} else if (tail(dclima, 1)[,"month"] == 12 & tail(dclima, 1)[,"day"] < 31) {
  dclima <- dclima[dclima$year != as.integer(substr(tail(dclima, 1)[,"date"], 1, 4)),]
}

# check if the first date if after 1 of January
if (head(dclima, 1)[,"month"] > 1) {
  dclima <- dclima[dclima$year != as.integer(substr(head(dclima, 1)[,"date"], 1, 4)),]
} else if (head(dclima, 1)[,"month"] == 1 & head(dclima, 1)[,"day"] > 1) {
  dclima <- dclima[dclima$year != as.integer(substr(head(dclima, 1)[,"date"], 1, 4)),]
}


################################### Imputation of missing data ##########################################

cat(".................................................................................................\n")
cat("................................ Checking for missing climate data ..............................\n")
cat("... Missing data will be imputed as the mean of the values of the same day from other years ...\n")
cat(".................................................................................................\n")

# Suspend execution for 5 seconds
Sys.sleep(5)

# temperatura data
if (anyNA(dclima$mean_temp)) {
  cat("Some values of temperature data are missing. They will be imputed.\n")

  dclima$month_day <- paste(dclima$month, dclima$day, sep = "_")

  with_NA <- dclima[is.na(dclima$mean_temp),]
  no_NA <- dclima[!is.na(dclima$mean_temp), ]

  for (md in unique(with_NA$month_day)) {

    mean_month_day <- mean(no_NA[no_NA$month_day==md, "mean_temp"])

    dclima[is.na(dclima$mean_temp) & dclima$month_day==md, "mean_temp"] <- mean_month_day

  }
  rm(with_NA, no_NA, md, mean_month_day)
  dclima$month_day <- NULL
}

# precipitation data
if (anyNA(dclima$precip)) {
  cat("Some values of precipitation data are missing. They will be imputed.\n")

  dclima$month_day <- paste(dclima$month, dclima$day, sep = "_")

  with_NA <- dclima[is.na(dclima$precip),]
  no_NA <- dclima[!is.na(dclima$precip), ]

  for (md in unique(with_NA$month_day)) {

    mean_month_day <- mean(no_NA[no_NA$month_day==md, "precip"])

    dclima[is.na(dclima$precip) & dclima$month_day==md, "precip"] <- mean_month_day

  }
  rm(with_NA, no_NA, md, mean_month_day)
  dclima$month_day <- NULL
}


####################### Export dataset with only complete years and without missing data ##########################

write.table(
  dclima[,c("date","mean_temp","precip")],
  file.path(getwd(), "all_data.txt"),
  quote = FALSE, row.names = FALSE, sep = "\t"
)


################################### Aggregated monthly values of climate ##########################################

# precipitation
dclima_precip <- aggregate(dclima$precip, by=list(year=dclima$year, month=dclima$month), FUN=sum)
dclima_precip <- aggregate(dclima_precip$x, by=list(month=dclima_precip$month), FUN=mean)
colnames(dclima_precip) <- c("month","precip")

# temperature
dclima_temp <- aggregate(dclima$mean_temp, by=list(year=dclima$year, month=dclima$month), FUN=mean)
dclima_temp <- aggregate(dclima_temp$x, by=list(month=dclima_temp$month), FUN=mean)
colnames(dclima_temp) <- c("month","mean_temp")

# join the two tables
dclima_all <- merge(dclima_temp, dclima_precip, by="month")

rm(dclima_precip, dclima_temp)


############################### Export the aggregated monthly values of climate ###################################

write.table(dclima_all, file.path(getwd(), "aggregated_data.txt"), quote = FALSE, row.names = FALSE, sep = "\t")


############################################## Plots ######################################################

# the range of y-axis of temperature data will be half the range of the y-axis of precipitation data
# consider temperatures below zero

# set the minimum value of y axis for temperature and precipitation
if (floor(min(dclima_all["mean_temp"])) < 0) {
  temp_min <- math.floor(min(dclima_all["mean_temp"]))
  prec_min <- temp_min*2
} else {
  temp_min <- 0
  prec_min <- 0
}

# set the maximum value of y axis for temperature and precipitation
if (ceiling(max(dclima_all['precip']))%%2 != 0) {
  prec_max <- ceiling(max(dclima_all['precip'])) + 1
  temp_max <- prec_max/2
} else {
  prec_max <- ceiling(max(dclima_all['precip']))
  temp_max = prec_max/2
}

# set export
if (output_file_format=="jpeg") {
  jpeg(paste0(output_file_name, ".jpeg"))
}
if (output_file_format=="png") {
  jpeg(paste0(output_file_name, ".png"))
}
if (output_file_format=="tiff") {
  jpeg(paste0(output_file_name, ".tiff"))
}
if (output_file_format=="pdf") {
  jpeg(paste0(output_file_name, ".pdf"))
}
# set the margins of the figure (bottom, left, top, right)
# xpd=TRUE allows to print the legend outside the plot area
par(mar=c(5,5,5,5), xpd=TRUE)
# main plot
plot(dclima_all$precip, ylim=c(prec_min, prec_max), type='l', ylab='Precipitation (mm)', xlab='', col='blue', xaxt='n')
# add x labels
axis(1, at=c(1:12), labels=substr(month.name, 1, 3))
# add a series in the same plot
par(new=TRUE)
plot(dclima_all$mean_temp, ylim=c(temp_min, temp_max), type='l', ylab="", xlab='', col='red', xaxt='n', yaxt='n')
# add y axis at the right side
axis(4)
# add text and labels to the y axis at the right side
mtext('Mean temperature (Celsius degrees)', side=4, line=3)
# add text to the x axis
mtext('Months', side=1, line=3)
# add the main title; adj to the left
title(main=paste(your_site, " ", min(dclima$year), "-", max(dclima$year), sep=""),
      adj=0, cex.main=1, font.main=2, line = 3)
# add a legend; bty='n' does not draw legend box
# legend outside the plot area, aligned to the right
legend("topright", legend=c('Precipitation','Mean temperature'), inset = c(0, -0.12), y.intersp = 1,
       bty = "n", cex=0.9, lty=1, col=c('blue','red'))
# close device to export the image (create object garbage to avoid message in command line output)
garbage <- dev.off()
rm(garbage)


############################### Closing the application ######################################

cat(".................................................................................................................................\n")
cat("................................... Job successfully executed. Find your image in your working directory ........................\n")
cat("... The dataset with only complete years and without missing data has been exported in your working directory as all_data.txt ...\n")
cat("... The dataset with aggregated monthly values of climate has been exported in your working directory as aggregated_data.txt ....\n")
cat(".................................................................................................................................\n")
cat(".......................................................... bye bye ;-) ..........................................................\n")
cat(".................................................................................................................................\n")

# Suspend execution for 5 seconds
Sys.sleep(5)

quit(save = "no")

