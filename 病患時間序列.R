setwd("C:\\RRR")
patients_table=read.csv("C:\\RRR\\patients.csv",header = T)
library(dplyr)
library(forecast)
library(ggfortify)
library(changepoint)
library(reshape2)

#歷年全台病患人數
count_table=data.frame(c(1:15))
rownames(count_table)[1:15]=c(2004:2018)

#每年病患人數
for(i in c(2004:2018)){
patients_table %>%
  select(c(研判年份,確定病例數))%>%
  filter(.[,1]==i)%>%
  select(確定病例數)%>%
  sum()->count_table[i-2003,1]
}
tour_table=data.frame(c(1:15))

for(i in c(2004:2018)){
  patients_table %>%
    select(c(研判年份,確定病例數,是否為境外移入))%>%
    filter(.[,1]==i)%>%
    filter(.[,3]=="是")%>%
    select(確定病例數)%>%
    sum()->tour_table[i-2003,1]
}
tour_annualy=ts(tour_table[,1],frequency = 1,start = c(2004))  
plot(tour_annualy,lwd=5,col="red",xaxt="n",
     xlab="年份",ylab="人數",main="台灣各年境外移入登革病患人數")
axis(1,c(2004:2018))

#各縣市病患人數
#for(i in c(2004:2018)){
patients_table %>%
    select(c(確定病例數,縣市))%>%
    arrange(縣市)->kk
list_county=as.list(unique(kk[,2]))
length(list_county)#22個縣市

county_table=data.frame()
for(i in c(1:length(list_county))){
  county_table[i,1]=list_county[i]
  kk%>%
    filter(.[,2]==list_county[[i]])%>%
    select(確定病例數)%>%
    sum()->county_table[i,2]
}

county_table=county_table[order(county_table[,2],decreasing = T),]
county_table=t(county_table)
colnames(county_table)=county_table[1,]
county_table=county_table[-1,1:10]
county_table=t(county_table)
barplot(county_table,main = "各縣市登革熱病患人數")

  
#台中境外移入比例
taichung_tour=data.frame()
for(i in c(2004:2018)){
  patients_table %>%
    select(c(研判年份,確定病例數,是否為境外移入,縣市))%>%
    filter(.[,1]==i)%>%
    filter(.[,3]=="是")%>%
    filter(.[,4]=="台中市")%>%
    select(確定病例數)%>%
    sum()->taichung_tour[i-2003,1]
}

taichung_tour_ts=ts(taichung_tour,frequency = 1,start = c(2004))
plot(taichung_tour_ts,lwd=5,col="red",xaxt="n",
     xlab="年份",ylab="人數",main="台中各年境外移入登革病患人數")
axis(1,c(2004:2018))


count_annualy=ts(count_table[,1],frequency = 1,start = c(2004))  
plot(count_annualy,lwd=5,col="red",xaxt="n",
        xlab="年份",ylab="人數",main="台灣各年登革病患人數")
axis(1,c(2004:2018))

#每年每月病患人數
count_monthly=data.frame()
for(i in c(2004:2018)){
    for (j in c(1:12)) {
      patients_table%>%
        select(c(研判年份,確定病例數,月份))%>%
        filter(.[,1]==i)%>%
        filter(.[,3]==j)%>%
        select(確定病例數)->ccc
      if (nrow(ccc)==0){
        count_monthly[(i-2004)*12+j,1]=0
      }
      else{
        count_monthly[(i-2004)*12+j,1]=sum(ccc)
      }  
  }
}


monthly_ts=ts(count_monthly[,1],frequency = 12,start=c(2004,1))
ts.plot(monthly_ts)
seasonplot(monthly_ts,year.labels=TRUE, year.labels.left=TRUE,
           col=1:50, pch=19,lwd=2,xlab="月份",ylab="人數",main="台灣每年各月登革病患人數")

fit_taiwan=decompose(monthly_ts, type="mult")
plot(fit_taiwan)
plot(fit_taiwan$seasonal[1:12],pch=19,xaxt="n",xlab="月份",
     ylab="",main="台灣登革熱病患季節因素")
axis(1,c(1:12))

reg_taiwan=tslm(monthly_ts~season+trend)
summary(reg_taiwan)

#九月和trend的p-value<0.05
#代表九月是台灣的登革熱高峰期，且有穩定增長的趨勢
#但調整後的R平分只有0.04959
#做時間序列迴歸

#台中市各年病患人數
taichung_annually=data.frame()
for(i in c(2004:2018)){
    patients_table%>%
    filter(.[,3]=="台中市")%>%
    select(c(研判年份,確定病例數))%>%
    filter(.[,1]==i)%>%
    select(確定病例數)%>%
    sum()->taichung_annually[i-2003,1]
}

taichung_count=ts(taichung_annually[,1],frequency = 1,c(2004))

plot(taichung_count, xaxt = "n",
     main="台中歷年登革熱病患人數",xlab="年份",ylab="人數",lwd=5)
axis(1,c(2004:2018))
#2018年病患暴增

#來看臺中各月表現
taichung_2018monthly=data.frame()
for(i in c(2004:2018)){
  for (j in c(1:12)) {
    patients_table%>%
      filter(.[3]=="台中市")%>%
      select(c(研判年份,確定病例數,月份))%>%
      filter(.[,1]==i)%>%
      filter(.[,3]==j)%>%
      select(確定病例數)->ccc
    if (nrow(ccc)==0){
      taichung_2018monthly[(i-2004)*12+j,1]=0
    }
    else{
      taichung_2018monthly[(i-2004)*12+j,1]=sum(ccc)
    }  
  }
}


taichung_monthly_ts=ts(taichung_2018monthly[,1],frequency = 12,start=c(2004,1))
reg_taichung= tslm(taichung_monthly_ts~season+trend)
summary(reg_taichung)

fit_taichung=decompose(taichung_monthly_ts, type="mult")
plot(fit_taichung)
#九月和trend的p-value<0.05
#代表台中九月為登革熱高峰期
#台中登革熱患者數有穩定成長趨勢
#調整後的R平方只有0.2366，解釋力不高

ts.plot(taichung_monthly_ts)
seasonplot(taichung_monthly_ts,year.labels=TRUE, year.labels.left=TRUE,
           col=1:50, pch=19,lwd=2,xlab="月份",ylab="人數",main="台中每年各月登革熱病患人數")

#2018年台中各鄉鎮病患人數
###
patients_table%>%
  filter(.[,3]=="台中市")%>%
  filter(.[,1]==2018)%>%
  select(c(鄉鎮,確定病例數))%>%
  table()%>%
  as.data.frame()->taichung_2018
taichung_2018%>%
  filter(.[,3]>0)->taichung_2018


dcast(taichung_2018,formula = 鄉鎮~ Freq*確定病例數)->ddd
ddd[is.na(ddd)]<-0

for(i in c(1:nrow(ddd))){
  ddd[i,2]=sum(ddd[i,-1])
}
taichung_2018=ddd[,1:2]
taichung_2018=taichung_2018[order(taichung_2018[,2],decreasing = T),]

taichung_2018=t(taichung_2018)
colnames(taichung_2018)=taichung_2018[1,]
taichung_2018=taichung_2018[-1,1:15]
taichung_2018=t(taichung_2018)
barplot(taichung_2018,main = "2018台中各鄉鎮登革熱病患人數",ylab="人數")

###################
#台南市歷年病患人數

tainan_annually=data.frame()
for(i in c(2004:2018)){
  patients_table%>%
    filter(.[,3]=="台南市")%>%
    select(c(研判年份,確定病例數))%>%
    filter(.[,1]==i)%>%
    select(確定病例數)%>%
    sum()->tainan_annually[i-2003,1]
}

tainan_count=ts(tainan_annually[,1],frequency = 1,c(2004))
plot(tainan_count, xaxt = "n",
     main="台南歷年登革熱病患人數",xlab="年份",ylab="人數",lwd=5)
axis(1,c(2004:2018))
##2015年暴增到兩萬多人

#台南市2015年各鄉鎮病患人數
patients_table%>%
  filter(.[,3]=="台南市")%>%
  filter(.[,1]==2015)%>%
  select(c(鄉鎮,確定病例數))%>%
  table()%>%
  as.data.frame()->tainan_2015

tainan_2015%>%
  filter(.[,3]>0)->tainan_2015

dcast(tainan_2015,formula = 鄉鎮~ Freq*確定病例數)->ddd
ddd[is.na(ddd)]<-0

for(i in c(1:nrow(ddd))){
  ddd[i,2]=sum(ddd[i,-1])
}
tainan_2015=ddd[,1:2]
tainan_2015=tainan_2015[order(tainan_2015[,2],decreasing = T),]

#繪圖
tainan_2015=t(tainan_2015)
colnames(tainan_2015)=tainan_2015[1,]
tainan_2015=tainan_2015[-1,1:15]
tainan_2015=t(tainan_2015)
barplot(tainan_2015,main = "2015台南各鄉鎮登革熱病患人數",ylab="人數")

#來看臺南各月病患數量
tainan_monthly=data.frame()
for(i in c(2004:2018)){
  for (j in c(1:12)) {
    patients_table%>%
      filter(.[3]=="台南市")%>%
      select(c(研判年份,確定病例數,月份))%>%
      filter(.[,1]==i)%>%
      filter(.[,3]==j)%>%
      select(確定病例數)->ccc
    if (nrow(ccc)==0){
      tainan_monthly[(i-2004)*12+j,1]=0
    }
    else{
      tainan_monthly[(i-2004)*12+j,1]=sum(ccc)
    }  
  }
}




tainan_monthly_ts=ts(tainan_monthly[,1],frequency = 12,start=c(2004,1))

reg_tainan= tslm(tainan_monthly_ts~season+trend)
summary(reg_tainan)

fit_tainan=decompose(tainan_monthly_ts, type="mult")
plot(fit_tainan)

#九月的p-value<0.05
#代表台南九月為登革熱高峰期
#解釋力太低

tainan_monthly_2014=ts(tainan_monthly[-133:-144,1],frequency = 12,start=c(2004,1))
fit_tainan=decompose(tainan_monthly_2014, type="mult")

reg_tainan_2014= tslm(tainan_monthly_2014~season+trend)
summary(reg_tainan_2014)

plot(fit_tainan)

#########################
#試試看用季節性
tainan_season=data.frame()
for(i in c(2004:2018)){
  for (j in c(1:4)) {
    patients_table%>%
      filter(.[3]=="台南市")%>%
      select(c(研判年份,確定病例數,季節))%>%
      filter(.[,1]==i)%>%
      filter(.[,3]==j)%>%
      select(確定病例數)->ccc
    if (nrow(ccc)==0){
      tainan_season[(i-2004)*4+j,1]=0
    }
    else{
      tainan_season[(i-2004)*4+j,1]=sum(ccc)
    }  
  }
}

tainan_season_ts=ts(tainan_season[,1],frequency = 4,start=c(2004,1))
tainan_season_2014=ts(tainan_season[1:44,1],frequency = 4,start=c(2004,1))

reg_tainan_season_2014= tslm(tainan_season_2014~season+trend)
summary(reg_tainan_season)

#R平方仍然很小


#########################


ts.plot(tainan_monthly_ts)
seasonplot(tainan_monthly_ts,year.labels=TRUE, year.labels.left=TRUE,
           col=1:50, pch=19,lwd=2,xlab="月份",ylab="人數",main="台南每年各月登革熱病患人數")


###################
#高雄市各年病患人數

kaoshung_annually=data.frame()
for(i in c(2004:2018)){
  patients_table%>%
    filter(.[,3]=="高雄市")%>%
    select(c(研判年份,確定病例數))%>%
    filter(.[,1]==i)%>%
    select(確定病例數)%>%
    sum()->kaoshung_annually[i-2003,1]
}

kaoshung_count=ts(kaoshung_annually[,1],frequency = 1,c(2004))
plot(kaoshung_count, xaxt = "n",
     main="高雄歷年登革熱病患人數",xlab="年份",ylab="人數",lwd=5)
axis(1,c(2004:2018))


#2014年高雄各鄉鎮病患人數
patients_table%>%
  filter(.[,3]=="高雄市")%>%
  filter(.[,1]==2014)%>%
  select(c(鄉鎮,確定病例數))%>%
  table()%>%
  as.data.frame()->kaoshung_2014

kaoshung_2014%>%
  filter(kaoshung_2014[,3]>0)->kaoshung_2014

dcast(kaoshung_2014,formula = 鄉鎮~ Freq*確定病例數)->ddd
ddd[is.na(ddd)]<-0

for(i in c(1:nrow(ddd))){
  ddd[i,2]=sum(ddd[i,-1])
}
kaoshung_2014=ddd[,1:2]
kaoshung_2014=kaoshung_2014[order(kaoshung_2014[,2],decreasing = T),]

#繪圖
kaoshung_2014=t(kaoshung_2014)
colnames(kaoshung_2014)=kaoshung_2014[1,]
kaoshung_2014=kaoshung_2014[-1,1:15]
kaoshung_2014=t(kaoshung_2014)
barplot(kaoshung_2014,main = "2014高雄各鄉鎮登革熱病患人數")        

#2015年高雄各鄉鎮病患人數
patients_table%>%
  filter(.[,3]=="高雄市")%>%
  filter(.[,1]==2015)%>%
  select(c(鄉鎮,確定病例數))%>%
  table()%>%
  as.data.frame()->kaoshung_2015

kaoshung_2015%>%
  filter(kaoshung_2015[,3]>0)->kaoshung_2015

dcast(kaoshung_2015,formula = 鄉鎮~ Freq*確定病例數)->ddd
ddd[is.na(ddd)]<-0

for(i in c(1:nrow(ddd))){
  ddd[i,2]=sum(ddd[i,-1])
}

kaoshung_2015=ddd[,1:2]
kaoshung_2015=kaoshung_2015[order(kaoshung_2015[,2],decreasing = T),]

#繪圖
kaoshung_2015=t(kaoshung_2015)
colnames(kaoshung_2015)=kaoshung_2015[1,]
kaoshung_2015=kaoshung_2015[-1,1:15]
kaoshung_2015=t(kaoshung_2015)
barplot(kaoshung_2015,main = "2015高雄各鄉鎮登革熱病患人數")

#高雄各年逐月病患數量
kaoshung_monthly=data.frame()
for(i in c(2004:2018)){
  for (j in c(1:12)) {
    patients_table%>%
      filter(.[3]=="高雄市")%>%
      select(c(研判年份,確定病例數,月份))%>%
      filter(.[,1]==i)%>%
      filter(.[,3]==j)%>%
      select(確定病例數)->ccc
    if (nrow(ccc)==0){
      kaoshung_monthly[(i-2004)*12+j,1]=0
    }
    else{
      kaoshung_monthly[(i-2004)*12+j,1]=sum(ccc)
    }  
  }
}


kaoshung_monthly_ts=ts(kaoshung_monthly[,1],frequency = 12,start=c(2004,1))

reg_kaoshung= tslm(kaoshung_monthly_ts~season+trend)
summary(reg_kaoshung)
#十一月和trend的p-value<0.05
#代表高雄十一月為登革熱高峰期，且有穩定增長的趨勢


seasonplot(kaoshung_monthly_ts,year.labels=TRUE, year.labels.left=TRUE,
           col=1:50, pch=19,lwd=2,xlab="月份",ylab="人數",main="高雄每年各月登革熱病患人數")


#全比例
plot(count_annualy,lwd=5,col="red",xaxt="n",ylim=c(0,45000),
     xlab="年份",ylab="人數",main="各年登革熱病患人數")
axis(1,c(2004:2018))
par(new=T)
plot(kaoshung_count+tainan_count,xlab="",ylab="",xaxt = "n",yaxt="n",ylim=c(0,45000),lwd=5)

legend("topleft",c("台南加高雄","全臺"), fill=c("black","red"), horiz=F,bty="n")

sum(kaoshung_count+tainan_count)
sum(count_annualy)
