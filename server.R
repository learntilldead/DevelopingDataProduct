library(shiny)
library(ggplot2)
library(caret)
library(Hmisc)
library(gbm)
library(ISLR)

data(Wage)
Wage = subset(Wage, select=-c(logwage))

xnames <- names(Wage)
xnames <- xnames[which(xnames!="wage" & xnames!="logwage")]
dnames <- xnames[which(xnames!="age")]

inTrain <- createDataPartition(y=Wage$wage, p=0.7, list=FALSE)
training <- Wage[inTrain,]
testing <- Wage[-inTrain,]

getFormulaFromVec = function(vec) {
  rhs <- paste(vec, collapse="+")
  as.formula(paste("wage~", rhs, sep=""))
}

shinyServer(
  function(input, output) { 
    ############## density plot ##############
    output$yControl <- renderUI({
      selectInput("y", "Category", xnames)
    })
    
    output$densityPlot <- renderPlot({
      if (input$method == 'density plot')
      {
        if (input$y != '')
        {
          if (input$y == 'age')
          {
            cutAge <- cut2(training$age, g=5)
            qplot(training$wage, color=factor(cutAge), geom="density",
                  xlab="wage", ylab="density", main="Density Plot") +
              labs(color=input$y)
          }
          else
          {
            qplot(training$wage, color=factor(training[,input$y]), geom="density",
                  xlab="wage", ylab="density", main="Density Plot") +
              labs(color=input$y)
          }
        }
      }
    })
    ############## end of density plot ##############
    
    ############## points plot ##############
    output$xControl <- renderUI({
      selectInput("x", "X", xnames)
    })
    
    output$colorControl <- renderUI({
      xnames2 <- xnames[which(xnames!=input$x)]
      selectInput("color", "Color", xnames2)
    })

    output$pointsPlot <- renderPlot({
      if (input$method == 'points plot')
      {
        if (input$x != '' & input$color != '')
        {
          qplot(training[,input$x], training$wage, color=training[,input$color], geom="jitter",
                xlab=input$x, ylab="wage", main="Points Plot") +
            labs(color=input$color)
        }
      }
    })
    ############## end of points plot ##############
    
    ############## Prediction plots ##############
    output$predictorControl <- renderUI({
      checkboxGroupInput('predictors', 'Predictors', xnames)
    })
    
    output$regressionPlot <- renderPlot({ 
      if (length(input$predictors) > 0)
      {
        regressionModel <- train(getFormulaFromVec(input$predictors), data=training, method="lm")
        regressionPrediction <- predict(regressionModel,newdata=testing)
        regressionRMSE <- sqrt(mean((regressionPrediction-testing$wage)^2))
        
        qplot(testing$wage, regressionPrediction, 
              xlab="actual wages", ylab="predicted wages", 
              xlim=c(0,300), ylim=c(0,300),
              main=paste("Prediction Result (RMSE = ", regressionRMSE, ")", sep="")) +
          geom_abline(slope=1)
      }
    })
    
    output$boostingPlot <- renderPlot({
      if (length(input$predictors) > 0)
      {
        boostingModel <- train(getFormulaFromVec(input$predictors), method="gbm", data=training, verbose=FALSE)
        boostingPrediction <- predict(boostingModel,newdata=testing)
        boostingRMSE <- sqrt(mean((boostingPrediction-testing$wage)^2))
        
        qplot(testing$wage, boostingPrediction, 
              xlab="actual wages", ylab="predicted wages", 
              xlim=c(0,300), ylim=c(0,300),
              main=paste("Prediction Result (RMSE = ", boostingRMSE, ")", sep="")) +
          geom_abline(slope=1)
      }
    })
    ############## end of Prediction plots ##############
  })