Ecologists sometimes need to compute monthly values of climate parameters over the hydrological year, i.e. a time period of 12 months whose beginning differs from that of the calendar year.
The hydrological year is used because,for example, part of the precipitation that falls in late autumn and winter (from September to February in the northern hemisphere) may have some effects on the ecological processes and dynamics occurring in the subsequent spring and summer (from March to August).

Largely used climate databases, e.g. the KNMI Climate Explorer, normally provide datasets with monthly values of calendar years.
The KNMI Climate Explorer include tools to compute climate values over seasonal or annual time scale, but there is no option to get monthly values of the hydrological year with a custom-defined beginning.

The following function climatab permits to create a data frame of monthly climate values over the hydrological year whose beginning can vary between January and December of the year prior to the current year.

The function is written in R programming language.

To start with, import a data frame from the KNMI Climate Explorer

prec<-read.table('http://climexp.knmi.nl/data/bpeca3838_sum12_anom_1959:2016.dat')

prec<-round(prec,1)

this gives a data frame with 13 columns:
in column 1 there are the years; in columns 2-13 there are monthly sums of precipitation (Jan-Dec) per year

The data are from the meteorological station of Rota, Spain (coordinates: 36.64N,-6.33E,21.0m)

The function climatab has tow arguments, x and y

x is a data frame as prec

y is an integer ranging from 1 to 12, indicating the month of the previous year that the user defines as the beginning of the hydrological year.



#########################################################################################################################

Programming notes

The function climatab has been developed starting from the following script:

dat<-data.frame(year=c(100,101,102,103,104),matrix(rnorm(60,1000,200),5,12)) #generate a data frame

dat<-round(dat,0) # round decimal digits

dat[,c(10:13)]

rbind(c(0,0),dat[,c(10:13)])

nrow(rbind(c(0,0),dat[,c(10:13)]))-1

rbind(c(0,0),dat[,c(10:13)])[c(1:(nrow(rbind(c(0,0),dat[,c(10:13)]))-1)),]

new.dat<-cbind(rbind(c(0,0),dat[,c(10:13)])[c(1:(nrow(rbind(c(0,0),dat[,c(10:13)]))-1)),],dat

colnames(new.dat)=c(paste('pr',colnames(new.dat)[1:4], sep=""),colnames(new.dat)[5:length(colnames(new.dat))])

which(colnames(new.dat)=='year')

which(colnames(new.dat)!='year')

fin.dat<-new.dat[,c(which(colnames(new.dat)=='year'),which(colnames(new.dat)!='year'))]

#########################################################################################################################
