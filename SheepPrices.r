lapply(list("rvest","RSelenium"), install.packages)
library("rvest")
library("RSelenium")

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

View(Sheep_tables[[1]])#View one of the tables

############Weekly regional averages##########
#This one is a bit more tricky


URL2<-"http://beefandlamb.ahdb.org.uk/markets/auction-market-reports/weekly-gb-regional-averages/"

## Scrape the target URL out of the iframe
URL3<-read_html(URL2)%>%
  html_nodes("#autoIframe")%>%
  html_attr("src")

##Get the CSS codes for the buttons on the website

ButtonCSS<-read_html(URL3)%>%
  html_nodes("li")

#Store the button codes in a named list
Buttons<-as.list(paste0("#",do.call(rbind,strsplit(as.character(ButtonCSS),"\""))[,2]))
names(Buttons)<-html_text(ButtonCSS)


#In this case, the data are calculated in response to a button click
#rvest can't click buttons so we have to switch to selenium to simulate a button click
#If I figure out how to do it in rvest I'll let you know
#I use chrome but you can use selenium with other browser
#Also no idea if this will work behind the firewall

#####Do not close the browser window that pops up######

#open URL 
driver<- rsDriver(browser=c("chrome"))
remDr <- driver[["client"]]
remDr$navigate(URL3)


#Click button for Great Britain
Button<-remDr$findElement(using = 'css',Buttons$`Great Britain`)
Button$clickElement()

Sys.sleep(2)#pause to allow page to load


###Extract the market data tables as a character vector
##IU don't think there is an equivalent of html_table for Rselenium
t <- remDr$findElements(using = 'css', ".market-data")
Tables<-as.character(sapply(t, function(x){x$getElementText()}))

##Example function for getting a table out of the list of tables
##Probably will need adjusting depending on the table
parse.table<-function (x, rows){
  Rows<-unlist(strsplit(x,"\n"))
  return(do.call(rbind,strsplit(Rows[rows],"\\ [0-9]")))
}

View(parse.table(Tables[2],rows=c(5:16)))
