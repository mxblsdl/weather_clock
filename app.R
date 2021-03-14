
# TODO separete out to different scripts
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
options(shiny.autoreload = T)

# time and date display function
time_display <- function(secs = 0) {
    format(strptime(gsub(".* ", "", Sys.time()), format='%H:%M') + secs, '%r')
}


date_display <- function(days = 0) {
    sub(".*?-", "", Sys.Date() + days)
}

# ui functions
# TODO make sure this refreshes
dateUI <- function() {
    fluidRow(id = "date", 
             Sys.Date(),
             span(class = "right",
                  "Last Updated:",
                  time_display(0)
             )
    )
}

# modules
iconUI <- function(id) {
    ns <- NS(id)
    uiOutput(ns("fore"))
}

# create icon and short weather widgwet
iconServer <- function(id, icon, temp) {
    moduleServer(id,
           function(input, output, session) {
               output$fore <- renderUI({
                   ns <- session$ns
                   div(
                       tags$i(id = ns("img"),
                              class = paste(icon, "icon")),
                       # TODO forecast
                       span(id = ns("short"), "mostly cloudy"),
                      # TODO add logic to change temp
                      # TODO pull in units
                        div(id = ns("tem"), 
                            temp, 
                            HTML("<span>F&#176;</span>"))
                   )
               })  
           })
}

library(shiny)
library(reticulate)

# make sure to set which python
use_python("usr/bin/python3")

# install api package
# py_install("noaa-sdk", pip = T)

# Source python function
source_python("../py/forecast.py")

# call observation for zip code
# Returns six and a half days of weather
forecast <- get_observations("97218")

# get date and time for given forecast
get_date_time <- function(starttime) {
    d <- gsub("(T.*)", "", starttime)
    t <- gsub("(.*T)", "", starttime)
    t <- gsub("^([^:]*:[^:]*).*", "\\1", t)
    return(list(d,t))
}

# unlist function
fore_unlist <- function(list, n) {
    unlist(list[n], recursive = F)
}

# select icon function
# TODO add as needed
fore_icon <- function(fore) {
    return(
        switch(fore,
               "Partly Cloudy" = "bi-cloud-sun",
               "Mostly Cloudy" = "bi-cloudy",
               "Cloudy" = "bi-clouds",
               "Slight Chance Rain Showers" = "bi-cloud-drizzle",
               "Chance Light Rain" = "bi-cloud-drizzle",
               "Rain Showers Likely" = "bi-cloud-rain",
               "Partly Sunny" = "bi-cloud-sun",
               "Mostly Sunny" = "bi-sun")
    )
}

# Define UI for application that draws a histogram
ui <- fluidPage(
    # Include bootstrap icons
    # https://icons.getbootstrap.com/
    tags$head(
        tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.0/font/bootstrap-icons.css")
    ),
    # TODO move to css file
    tags$style(
        "
        div{
        border-color:red;
        border-style:solid;
        border-width:1px;
        }
        .icon{
        font-size:4em;
        }
        .right{
        float:right;
        }
        #date{
        margin-left:10px;
        margin-right:10px;
        }
        "
    ),
    
    # Application title
    titlePanel("Weather Clock"),

    # display date and time
    dateUI(),
    
    # display weather results
    fluidRow(
        column(3,
            h4("Current"),
            iconUI("now"),
        ), 
        column(3,
               offset = 1,
               h4(time_display(3600)),
               iconUI("hour1")),
        column(3,
               offset = 1,
               h4(time_display(7200)),
               iconUI("hour2"))

    ),
    fluidRow(
        column(3,
               h4(date_display(1)),
               iconUI("next")),
        column(3,
               offset = 1,
               h4(date_display(2)),
               iconUI("next1")),
        column(3,
               offset = 1,
               h4(date_display(3)),
               iconUI("next2"))
        )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    now <- fore_unlist(forecast, 1)
    hour1 <- fore_unlist(forecast, 2)
    hour2 <- fore_unlist(forecast, 3)
    next1 <- fore_unlist(forecast, 24)
    next2 <- fore_unlist(forecast, 48)
    next3 <- fore_unlist(forecast, 72)
    
    # List time of forecast
    # TODO Show next day high lows
    # TODO add more arguments to module function
    iconServer("now",
               fore_icon(now$shortForecast),
               now$temperature)
    
    iconServer("hour1", 
               fore_icon(hour1$shortForecast),
               hour1$temperature)
    
    iconServer("hour2", 
               fore_icon(hour2$shortForecast),
               hour2$temperature)
    
    # TODO change next day to noon forecast
    iconServer("next1", 
               fore_icon(next1$shortForecast),
               next1$temperature)
    
    iconServer("next2", 
               fore_icon(next2$shortForecast),
               next2$temperature)
    
    iconServer("next3", 
               fore_icon(next3$shortForecast),
               next3$temperature)
}

# Run the application 
shinyApp(ui = ui, server = server)


