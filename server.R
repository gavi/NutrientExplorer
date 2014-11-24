library(shiny)
library(ggplot2)
library(ggvis)
#preload the data
nutdata<-read.csv("nutdata.csv")


shinyServer(
  function(input, output) {
    #output$distPlot <- renderPlot({
    #  ggplot(data,aes_string(x=input$x,y=input$y,color=input$c))+geom_point()
      # qplot(Energ_Kcal,Protein,data=data,color=Water)
    #})
    
    dt<-reactive({
      category<-input$category
      food_name<-tolower(input$food_name)
      if(category!="All"){
        d <- nutdata[nutdata[["FdGrp_Desc"]]==category,]
      }
      else{
        d<-nutdata
      }
      if(food_name!=""){
        d<-d[grepl(food_name,tolower(d[["Shrt_Desc"]])),]
      }
      d
    })
    
    
    
    food_tooltip <- function(x) {
      if (is.null(x)) return(NULL)
      if (is.null(x$NDB_No)) return(NULL)
      
      # Pick out the food with this NDB_No
      all_data <- isolate(nutdata)
      food <- all_data[all_data$NDB_No == x$NDB_No, ]
      
      paste0("<b>", food$Long_Desc, "</b><br>",
             food$FdGrp_Desc, "<br>"
      )
    }
    food_detail <- function(data,location, ...){
      if (is.null(data)) return(NULL)
      if (is.null(data$NDB_No)) return(NULL)
      
      # Pick out the food with this NDB_No
      all_data <- isolate(nutdata)
      food <- all_data[all_data$NDB_No == data$NDB_No, ]
      html<- sprintf("%s<hr><table class='table'>",unlist(food["Long_Desc"]))
      cols<-colnames(food)
      cols<-cols[!cols %in% c("Shrt_Desc","Long_Desc","FdGrp_Desc","GmWt_1","GmWt_Desc1","GmWt_2","GmWt_Desc2","Refuse_Pct")]
      for(col in cols){
          html<-sprintf("%s<tr><td><strong>%s</strong></td><td>%s</td></tr>",html,col,unlist(food[col]))
        
      }
      html<- sprintf("%s%s",html,"</table>")
      output$values<-renderText(html)
    } 
    
    vis <- reactive({
      data<-dt()
      xvar <- prop("x", as.symbol(input$x))
      yvar <- prop("y", as.symbol(input$y))
      fill <- prop("fill",as.symbol(input$c))
      
      data %>%
        ggvis(x = xvar, y = yvar ,fill=fill) %>%
        layer_points(size := 50, size.hover := 200,
                     fillOpacity := 0.2, fillOpacity.hover := 0.5,
                     key := ~NDB_No) %>%
        add_tooltip(food_tooltip, "hover") %>%
        handle_click(food_detail) %>%
        set_options(width = 500, height = 500)
    })
    
    vis %>% bind_shiny("plot1")
  
    output$corr<-renderText(sprintf("Correlation between %s and %s is <strong>%f</strong>",input$x,input$y,cor(dt()[[input$x]],dt()[[input$y]],use="pairwise.complete.obs")))
    
})