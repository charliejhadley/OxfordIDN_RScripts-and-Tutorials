install.packages('WDI')
library(WDI)


dat <- WDI(indicator=c('NY.GDP.PCAP.KD',"BN.CAB.XOKA.GD.ZS"), country=c('MX','CA','US'), start=1960, end=2012)

str(dat)


read.csv("Data_Extract_From_World_Development_Indicators_Data.csv")

file.exists("Data_Extract_From_World_Development_Indicators_Data.csv")
