if (!require("pacman")) install.packages("pacman")
pacman::p_load(rvest)



###########Deadweight Sheep Price Reporting#######

URL<-"http://beefandlamb.ahdb.org.uk/markets/deadweight-price-reports/deadweight-sheep-price-reporting/"


##Scraping workflow using rvest
X<-read_html(URL)%>%
  html_nodes("#autoIframe")%>%
  html_attr("src")%>% ##The actual data is in a table embedded in an iframe so we have to scrape the real URL first
  read_html()%>%
  html_nodes(".market-data")

##Output a list of the two tables 
Sheep_tables<-html_table(X[c(2,4)])

############Weekly regional averages##########
URL2<-"http://beefandlamb.ahdb.org.uk/markets/auction-market-reports/weekly-gb-regional-averages/

## Scrape the target URL out of the iframe
URL3<-read_html(URL2)%>%
  html_nodes("#autoIframe")%>%
  html_attr("src")

#In this case, the data are calculated in response to a button click
#rvest can't click buttons so we have to switch to selenium to simulate a button click

