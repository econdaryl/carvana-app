#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
carvana <- read.csv("carvana_clean.csv", stringsAsFactors = TRUE)
library(shiny)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(shinythemes)
library(formattable)

# Define UI for application that draws a histogram
ui <- fluidPage(
    #shinythemes::themeSelector(),
    theme = shinytheme("readable"),
    # Application title
    titlePanel("Predicted Car Price"),

    # Sidebar with iterative choices
    sidebarPanel(
        uiOutput("select_make"),
        uiOutput("select_model"),
        uiOutput("select_trim"),
        numericInput('miles', 'Input Mileage', 0, 0, step = 1000),
        numericInput('year', 'Input Year', 2007, 2007, 2020)
        ),

    # Show a plot of the generated distribution
    mainPanel(
       textOutput("regression"),
       plotOutput("scatter"),
       textOutput("source")
    )
)

# Define server logic
server <- function(input, output, session) {

    output$select_make <- renderUI({
        
    selectizeInput('make', 'Select Make', choices = levels(carvana$make), selected=levels(carvana$make)[14])
    
    })
    
    output$select_model <- renderUI({
        req(input$make)
        choice_model <- reactive({
            carvana %>%
                filter(make == input$make) %>%
                pull(model) %>%
                as.character()
        
            })
        selectizeInput('model', 'Select Model', choices = choice_model(), selected=levels(carvana$model)[1])
    
    })
    output$select_trim <- renderUI({
        req(input$make)
        req(input$model)
        choice_trim <- reactive({
            carvana %>%
                filter(make == input$make) %>%
                filter(model == input$model) %>%
                pull(trim) %>%
                as.character()
        })
        
    selectizeInput('trim', 'Select Trim', choices = c("select" = "", choice_trim()))
    
    })
    output$regression <- renderText({
        req(input$make)
        req(input$model)
        req(input$trim)
        if (sum(with(carvana, make==input$make & model==input$model & trim==input$trim))>=10){
            pred <- reactive({
                mod <- carvana %>%
                    filter(make == input$make,
                           model == input$model,
                           trim == input$trim) %>%
                    mutate(milesq = mileage^2) %>%
                    lm(price ~ mileage + year, data = .)
                mod$coefficients[[1]] + input$miles*mod$coefficients[[2]] + input$year*mod$coefficients[[3]]
            })
        } else if (length(unique(carvana$trim[which(carvana$make==input$make & carvana$model==input$model)]))==1) {
            pred <- reactive({
                mod <- carvana %>%
                    filter(make == input$make,
                           model == input$model) %>%
                    mutate(milesq = mileage^2) %>%
                    lm(price ~ mileage + year, data = .)
                mod$coefficients[[1]] + input$miles*mod$coefficients[[2]] + input$year*mod$coefficients[[3]]
            })
        } else {
            pred <- reactive({
                mod <- carvana %>%
                    filter(make == input$make,
                           model == input$model) %>%
                    mutate(milesq = mileage^2) %>%
                    lm(price ~ mileage + year + trim, data = .)
                trimn <- paste0('trim', as.character(input$trim))
                mod$coefficients[[1]] + mod$coefficients[trimn] + input$miles*mod$coefficients[[2]] + input$year*mod$coefficients[[3]]
            })
        }
        paste0("The predicted price of this car is ", currency(pred()))
    })
    output$scatter <- renderPlot({
        req(input$make)
        req(input$model)
        data <- carvana %>%
            filter(make == input$make,
                   model == input$model)
        ggplot(data=data, aes(x = mileage, y = price)) +
            geom_point(alpha = 1, aes(color = as.factor(year), shape = trim)) +
            scale_shape_manual(values = seq(0, 20)) +
            #scale_color_brewer(palette = "YlGnBu", direction = 1) +
            geom_smooth(method = 'glm', se = FALSE, size = 0.5, method.args=list(family=gaussian(link="log"))) +
            labs(color = "Year", shape = "Trim") +
            ylab("Price") +
            xlab("Mileage") +
            theme_classic()
    })
    output$source <- renderText({
        "Source: Carvana Listings, July 2019"
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
