library(shiny)
library(ggvis)
data<-read.csv("nutdata.csv")

shinyUI(fluidPage(
  titlePanel("Nutrient Explorer"),
  fluidRow(
    column(3,
           wellPanel(
                h4("Graphing Options"),
                
                selectInput("x", 
                            label = "Choose the X-Axis",
                            choices = as.list(colnames(data)[3:48]),
                            selected = "Energ_Kcal"),
                selectInput("y", 
                            label = "Choose the Y-Axis",
                            choices = as.list(colnames(data)[3:48]),
                            selected = "Lipid_Tot"),
                
                selectInput("c", 
                            label = "Color",
                            choices = as.list(colnames(data)[3:48]),
                            selected = "Water")
              
              ),
              wellPanel(
                h4("Filters"),
                selectInput("category",
                            label="Food Category",
                            choices=as.list(c("All",as.vector(unique(data$FdGrp_Desc))))),
                textInput("food_name",label="Food Name")
              )),
    column(6,
           ggvisOutput("plot1"),
           #renderPlot("distPlot"),
           wellPanel(
              htmlOutput("corr")
             )
           ),
    column(3,
           wellPanel(htmlOutput("values"))
           )
    
        )
  )
  );