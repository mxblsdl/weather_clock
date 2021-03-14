library(rnoaa)

isd()
rnoaa::ncdc()
  
  https://api.weather.gov/points/{latitude},{longitude}
library(httr)
library(jsonlite)
  

  
res <- GET("https://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?zipCodeList=97218&product=glance&begin=2021-03-01T00:00:00&end=2021-03-23T00:00:00")

con <- content(res, as = "text")

js <- toJSON(con, pretty = T)

# noaa api tokennc
token = "bWSqSUsNywDUkDJnxRIMtrojqjcqFHrZ"

noaa(datasetid = "PRECIP_HLY", locationid = "ZIP:28801", datatypeid = "HPCP",
     limit = 5, token = token)

ncdc(datasetid = "PRECIP_HLY", stationid = "GHCND:USC00356750", startdate = "2021-03-01", enddate = "2021-03-02", token = token)



