join_climatabwin<-function(x,y,method){
  madetab<-climatab(x,y)
  listout<-list()
  for (k in 1:length(colnames(madetab)[-c(1,length(colnames(madetab)))])) {
    listout[[k]]<-climawindow(madetab,colnames(madetab)[-c(1,length(colnames(madetab)))][k],method)
  }
  for (i in 1:length(listout)) {
    listout[[i]]<-listout[[i]][-grep('year',listout[i])]
  }
  listout_dframe<-as.data.frame(listout)
  return(cbind(madetab,listout_dframe))
}