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

iconServer <- function(id, icon, temp) {
    moduleServer(id,
           function(input, output, session) {
               output$fore <- renderUI({
                   ns <- session$ns
                   div(
                       # TODO add logic here to change icon
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
source_python("forecast.py")

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

# define times for forecast
times <- c(1,2,3, 24, 48, 72)
forecast_trim <- forecast[times]

# unlist function
unlist_forecast <- function(list, n) {
    unlist(list[n], recursive = F)
}

# create objects to display
now <- unlist_forecast(forecast, 1)
hour_2 <- unlist_forecast(forecast, 2)
hour_3 <- unlist_forecast(forecast, 3)
day_2 <- unlist_forecast(forecast, 4)
day_3 <- unlist_forecast(forecast, 5)
day_4 <- unlist_forecast(forecast, 6)

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
    
    # TODO add logic for which cloud to pass
    # TODO add more arguments to module function
    iconServer("now", "bi-cloud", 5)
    iconServer("hour1", "bi-sun", 5)
    iconServer("hour2", "bi-sun", 5)
    
    # TODO change next day to noon forecast
    iconServer("next", "bi-sun", 5)
    iconServer("next1", "bi-sun", 5)
    iconServer("next2", "bi-sun", 5)
}

# Run the application 
shinyApp(ui = ui, server = server)


