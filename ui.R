library(shiny)

shinyUI(navbarPage(
  "",
  tabPanel(
    "Application",
    sidebarLayout(
      
      sidebarPanel(
        h3('Plotting Predictors'),
        
        selectInput('method', 'Plotting Method', c('', 'density plot', 'points plot')),
        
        conditionalPanel(
          condition = "input.method == 'density plot'",
          selectInput('fixedX', 'X', 'wage'),
          uiOutput('yControl')
        ),
        
        conditionalPanel(
          condition = "input.method == 'points plot'",
          selectInput('fixedY', 'Y', 'wage'),
          uiOutput('xControl'),
          uiOutput("colorControl")
        ),
        
        h3('Performing Prediction'),
        
        selectInput('predMethod', 'Prediction Method', 
                    c('', 'Linear Regression', 'Boosting')),
        
        conditionalPanel(
          condition = "input.predMethod == 'Boosting'",
          p("Boosting is slow!", style="color: red")
        ),
        
        conditionalPanel(
          condition = "input.predMethod != ''",
          uiOutput('predictorControl')
        )
      ),
      
      mainPanel(
        conditionalPanel(
          condition = "input.method == 'density plot'",
          plotOutput('densityPlot')
        ),
        conditionalPanel(
          condition = "input.method == 'points plot'",
          plotOutput('pointsPlot')
        ),    
        conditionalPanel(
          condition = "input.predMethod == 'Linear Regression'",
          plotOutput('regressionPlot')
        ),
        conditionalPanel(
          condition = "input.predMethod == 'Boosting'",
          plotOutput('boostingPlot')
        )
      )
    )
  ),
  tabPanel(
    "Help",
    h3("Guideline"),
    p("This is a small demo of the prediction application. It can visualize the relationship 
      of the predictors and the outcome in the training set, and perform prediction on the 
      testing set based on user-selected predictors and prediction algorithm. "),
    p("The data used in the application is the Wage data from the ISLR package. The predictors 
      include year, age, sex, education, region, marital status and etc. You can find that in this dataset 
      sex and region have only one value for each."),
    p("There are two different types of plotting: density plot and points plot. Density plots show 
      the wage distribution under the category specified by the 'Category' input. Points plots show 
      the scattered wage points for values of the 'X' variable, at the same time colored by  
      the 'Color' variable. "),
    p("There are two prediction algorithms available in this application. One is the linear regression 
      method, the other is the boosting method. Users can also choose which predictors to use in the two 
      algorithms. Note that the boosting algorithm is much slower than the linear regression algorithm. 
      The prediction result is plotted on the right with RMSE calculated. ")
  )
))