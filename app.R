library(shiny)
library(ccharter)
ui <- fluidPage(
  titlePanel("Control Chart App"),
  sidebarLayout(
    sidebarPanel(
  fileInput(inputId = "file1", label = "Choose a CSV", accept=c('text/csv','text/comma-separated-values,text/plain','.csv')),
  actionButton(inputId = "go", label = "Analyze"),
    width = 3),
  mainPanel(
    plotOutput("ploti"),
    tableOutput("contents")
  
  )
  )
)

server <- function(input, output) {
  
  data_in <- eventReactive(input$go,{
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    read.csv(inFile$datapath, stringsAsFactors = FALSE)
    
  })
  
  data_out <- reactive({
    control.chart <- ccpoints(data_in(), colnames(data_in())[1], colnames(data_in())[2])
    control.chart[["data"]][,1] <- as.character(control.chart[["data"]][,1]) #shiny issue with dates
    control.chart[["data"]]
  })
  
  output$contents <- renderTable({
   data_out()
  })
  
  output$ploti <- renderPlot({
    control.chart <- ccpoints(data_in(), colnames(data_in())[1], colnames(data_in())[2])
    cc2plot(control.chart)
  })
  
}

shinyApp(ui = ui, server = server)