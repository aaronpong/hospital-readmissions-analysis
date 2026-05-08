library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)

ui <- dashboardPage(
  dashboardHeader(title = "Hospital Readmissions Analysis"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("hospital")),
      menuItem("By State", tabName = "state", icon = icon("map")),
      menuItem("By Condition", tabName = "condition", icon = icon("heartbeat")),
      menuItem("Regression Analysis", tabName = "regression", icon = icon("chart-line")),
      menuItem("Findings & Conclusions", tabName = "findings", icon = icon("clipboard-list"))
    ),
    selectInput("state_filter", "Filter by State:",
                choices = c("All", sort(unique(df$State))),
                selected = "All")
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("total_hospitals"),
                valueBoxOutput("avg_ratio"),
                valueBoxOutput("total_readmissions")
              ),
              fluidRow(
                box(title = "Top 20 Hospitals by Excess Readmission Ratio",
                    width = 12,
                    plotlyOutput("top_hospitals_plot"))
              )
      ),
      tabItem(tabName = "state",
              fluidRow(
                box(title = "Average Excess Readmission Ratio by State",
                    width = 12,
                    plotlyOutput("state_plot"))
              ),
              fluidRow(
                box(title = "State Summary Table",
                    width = 12,
                    dataTableOutput("state_table"))
              )
      ),
      tabItem(tabName = "condition",
              fluidRow(
                box(title = "Average Excess Readmission Ratio by Condition",
                    width = 12,
                    plotlyOutput("condition_plot"))
              ),
              fluidRow(
                box(title = "Condition vs State Heatmap",
                    width = 12,
                    plotlyOutput("heatmap_plot"))
              )
      ),
      tabItem(tabName = "regression",
              fluidRow(
                box(title = "Regression Model: Predictors of Excess Readmission Ratio",
                    width = 12,
                    verbatimTextOutput("regression_summary"))
              ),
              fluidRow(
                box(title = "Predicted vs Actual",
                    width = 6,
                    plotlyOutput("regression_plot")),
                box(title = "Coefficient Plot",
                    width = 6,
                    plotlyOutput("coef_plot"))
              )
      ),
      tabItem(tabName = "findings",
              fluidRow(
                box(title = "Project Overview", width = 12,
                    p("This dashboard analyzes hospital readmission data from the CMS Hospital Readmissions Reduction Program (HRRP) for fiscal year 2026. The dataset contains 8,037 observations across 2,477 hospitals in all 50 states, covering six medical conditions."),
                    p("Data source: Centers for Medicare and Medicaid Services (CMS) — data.cms.gov")
                )
              ),
              fluidRow(
                box(title = "Key Finding 1: Geographic Variation", width = 6, status = "danger",
                    p("Massachusetts, New Jersey, and Florida consistently show the highest average excess readmission ratios nationally, with MA reaching an average of 1.044. States in the Northeast tend to perform worse than states in the Mountain West and Pacific Northwest, suggesting regional healthcare system differences may play a role.")
                ),
                box(title = "Key Finding 2: Condition-Level Differences", width = 6, status = "warning",
                    p("Hip and knee replacement procedures show the highest excess readmission ratios among all six conditions analyzed. Heart failure and pneumonia account for the largest volume of readmissions overall. COPD shows the lowest average excess ratio, though variation across hospitals remains substantial.")
                )
              ),
              fluidRow(
                box(title = "Key Finding 3: Hospital-Level Outliers", width = 6, status = "warning",
                    p("A small number of hospitals show excess readmission ratios well above 1.2, indicating readmission rates significantly higher than expected for similar patient populations. Oroville Hospital in California and Winchester Hospital in Massachusetts ranked among the worst performers across multiple conditions.")
                ),
                box(title = "Key Finding 4: Regression Model Results", width = 6, status = "info",
                    p("A linear regression model predicting excess readmission ratio from hospital discharge volume, number of conditions reported, and total readmissions explained approximately 33% of the variation in performance (Adjusted R-squared = 0.33). All three predictors were statistically significant. Larger hospitals with higher discharge volumes tended to perform slightly better, while hospitals with higher total readmissions showed worse excess ratios.")
                )
              ),
              fluidRow(
                box(title = "Conclusions & Limitations", width = 12,
                    p("The findings suggest that readmission performance varies substantially across geography and condition type, and that hospital size and volume are modest but significant predictors of performance. These patterns may reflect differences in post-discharge care coordination, patient population characteristics, or regional healthcare infrastructure."),
                    p("This analysis is limited by the observational nature of the data. The regression model does not account for patient-level risk factors, socioeconomic variables, or hospital specialty type, all of which likely contribute to readmission rates. Future analysis could incorporate additional CMS datasets on hospital characteristics and patient demographics to build a more comprehensive predictive model."),
                    p("All analysis was conducted using PostgreSQL for data management and R/Shiny for statistical modeling and visualization.")
                )
              )
      )
    )
  )
)

server <- function(input, output) {
  
  #reactive statement
  filtered_df <- reactive({
    if (input$state_filter == "All") {
      df
    } else {
      df %>% filter(State == input$state_filter)
    }
  })
  
  output$total_hospitals <- renderValueBox({
    valueBox(
      value = length(unique(filtered_df()$Facility.ID)),
      subtitle = "Total Hospitals",
      icon = icon("hospital"),
      color = "blue"
    )
  })
  
  output$avg_ratio <- renderValueBox({
    valueBox(
      value = round(mean(filtered_df()$Excess.Readmission.Ratio, na.rm = TRUE), 3),
      subtitle = "Avg Excess Readmission Ratio",
      icon = icon("chart-line"),
      color = "red"
    )
  })
  
  output$total_readmissions <- renderValueBox({
    valueBox(
      value = format(sum(filtered_df()$Number.of.Readmissions, na.rm = TRUE), big.mark = ","),
      subtitle = "Total Readmissions",
      icon = icon("procedures"),
      color = "orange"
    )
  })
  
  output$top_hospitals_plot <- renderPlotly({
    top_hospitals <- filtered_df() %>%
      group_by(Facility.Name, State) %>%
      summarise(avg_ratio = mean(Excess.Readmission.Ratio, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(avg_ratio)) %>%
      head(20)
    
    plot_ly(top_hospitals, 
            x = ~avg_ratio, 
            y = ~reorder(Facility.Name, avg_ratio),
            type = "bar",
            orientation = "h",
            text = ~State,
            marker = list(color = "steelblue")) %>%
      layout(title = "Top 20 Hospitals by Excess Readmission Ratio",
             xaxis = list(title = "Avg Excess Readmission Ratio"),
             yaxis = list(title = ""))
  })
  output$state_plot <- renderPlotly({
    state_summary <- filtered_df() %>%
      group_by(State) %>%
      summarise(
        avg_ratio = mean(Excess.Readmission.Ratio, na.rm = TRUE),
        num_hospitals = n_distinct(Facility.ID),
        .groups = "drop"
      ) %>%
      arrange(desc(avg_ratio))
    
    plot_ly(state_summary,
            x = ~reorder(State, avg_ratio),
            y = ~avg_ratio,
            type = "bar",
            marker = list(color = ~avg_ratio, colorscale = "Reds")) %>%
      layout(xaxis = list(title = "State"),
             yaxis = list(title = "Avg Excess Readmission Ratio"),
             title = "Readmission Ratio by State")
  })
  
  output$state_table <- renderDataTable({
    filtered_df() %>%
      group_by(State) %>%
      summarise(
        Hospitals = n_distinct(Facility.ID),
        Avg_Excess_Ratio = round(mean(Excess.Readmission.Ratio, na.rm = TRUE), 4),
        Total_Readmissions = sum(Number.of.Readmissions, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(Avg_Excess_Ratio))
  })
  output$condition_plot <- renderPlotly({
    condition_summary <- filtered_df() %>%
      group_by(Measure.Name) %>%
      summarise(
        avg_ratio = mean(Excess.Readmission.Ratio, na.rm = TRUE),
        num_hospitals = n_distinct(Facility.ID),
        .groups = "drop"
      ) %>%
      arrange(desc(avg_ratio))
    
    plot_ly(condition_summary,
            x = ~reorder(Measure.Name, avg_ratio),
            y = ~avg_ratio,
            type = "bar",
            marker = list(color = "steelblue")) %>%
      layout(xaxis = list(title = "Condition"),
             yaxis = list(title = "Avg Excess Readmission Ratio",
                          range = c(0.99, 1.02)),
             title = "Readmission Ratio by Condition")
  })
  
  output$heatmap_plot <- renderPlotly({
    heatmap_data <- filtered_df() %>%
      group_by(State, Measure.Name) %>%
      summarise(avg_ratio = mean(Excess.Readmission.Ratio, na.rm = TRUE),
                .groups = "drop")
    
    plot_ly(heatmap_data,
            x = ~Measure.Name,
            y = ~State,
            z = ~avg_ratio,
            type = "heatmap",
            colorscale = "Reds") %>%
      layout(title = "Excess Readmission Ratio by State and Condition",
             xaxis = list(title = "Condition"),
             yaxis = list(title = "State"))
  })
  output$regression_summary <- renderPrint({
    model_df <- df %>%
      group_by(Facility.ID, Facility.Name, State) %>%
      summarise(
        avg_excess_ratio = mean(Excess.Readmission.Ratio, na.rm = TRUE),
        avg_discharges = mean(Number.of.Discharges, na.rm = TRUE),
        total_readmissions = sum(Number.of.Readmissions, na.rm = TRUE),
        num_conditions = n_distinct(Measure.Name),
        .groups = "drop"
      )
    
    model <- lm(avg_excess_ratio ~ avg_discharges + num_conditions + total_readmissions, 
                data = model_df)
    summary(model)
  })
  
  output$regression_plot <- renderPlotly({
    model_df <- df %>%
      group_by(Facility.ID, Facility.Name, State) %>%
      summarise(
        avg_excess_ratio = mean(Excess.Readmission.Ratio, na.rm = TRUE),
        avg_discharges = mean(Number.of.Discharges, na.rm = TRUE),
        total_readmissions = sum(Number.of.Readmissions, na.rm = TRUE),
        num_conditions = n_distinct(Measure.Name),
        .groups = "drop"
      )
    
    model <- lm(avg_excess_ratio ~ avg_discharges + num_conditions + total_readmissions,
                data = model_df)
    
    model_df$predicted <- predict(model)
    
    plot_ly(model_df,
            x = ~predicted,
            y = ~avg_excess_ratio,
            type = "scatter",
            mode = "markers",
            marker = list(color = "steelblue", opacity = 0.5),
            text = ~Facility.Name) %>%
      layout(xaxis = list(title = "Predicted Ratio"),
             yaxis = list(title = "Actual Ratio"),
             title = "Predicted vs Actual Excess Readmission Ratio")
  })
  
  output$coef_plot <- renderPlotly({
    model_df <- df %>%
      group_by(Facility.ID, Facility.Name, State) %>%
      summarise(
        avg_excess_ratio = mean(Excess.Readmission.Ratio, na.rm = TRUE),
        avg_discharges = mean(Number.of.Discharges, na.rm = TRUE),
        total_readmissions = sum(Number.of.Readmissions, na.rm = TRUE),
        num_conditions = n_distinct(Measure.Name),
        .groups = "drop"
      )
    
    model <- lm(avg_excess_ratio ~ avg_discharges + num_conditions + total_readmissions,
                data = model_df)
    
    coefs <- as.data.frame(summary(model)$coefficients)
    coefs$variable <- rownames(coefs)
    coefs <- coefs[-1,]
    
    plot_ly(coefs,
            x = ~Estimate,
            y = ~variable,
            type = "bar",
            orientation = "h",
            error_x = list(array = ~`Std. Error`),
            marker = list(color = ifelse(coefs$Estimate > 0, "red", "steelblue"))) %>%
      layout(xaxis = list(title = "Coefficient Estimate"),
             yaxis = list(title = ""),
             title = "Regression Coefficients")
  })
  
  
}

shinyApp(ui, server)