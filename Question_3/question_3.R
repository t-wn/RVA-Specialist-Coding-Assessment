# created March 8, 2026 on R v4.5.2

# ------------------
# Interactive R Shiny Application
# Integrate the visualization from Question 2 into an interactive dashboard.
# Requirements:
#  - Display the bar chart from Question 2 within a Shiny UI.
#  - Filter: Add a user input (e.g., selectInput or checkboxGroupInput) to filter the chart by Treatment Arm (ACTARM)
#  - Reactivity: The plot must update dynamically based on the selected filter.
#  - Tooling: Use the {shiny} framework.
# ------------------
# DATA PREPARATION FOR SHINY APP

# install and load following packages
# install.packages(c("pharmaverseadam", "tidyverse", "gtsummary", "ggplot2", "shiny"))

library(pharmaverseadam) 
library(tidyverse) 
library(gtsummary) 
library(ggplot2) 
library(shiny)

# load data from pharmaverseadam, assign to object
df_ae <- pharmaverseadam::adae # adverse events analysis

# Create a new dataset just for Question 3
# Unique number of Subjects per System Organ Class (SOC) and Severity Level
# include treatment arm variable to use for filtering in Shiny app later
df_ae_shiny <- df_ae %>%
  group_by(ACTARM, AESOC, AESEV) %>%
  summarize(
    N_UNIQSUBJID = n_distinct(USUBJID), 
    .groups = "drop") %>%
  filter(!is.na(AESEV)) # Drop missing severities if any exist

df_ae_shiny$AESEV <- factor(df_ae_shiny$AESEV, levels = c("SEVERE", "MODERATE", "MILD"))

# ------------------
# CREATE SHINY APP

# 1. User interface
ui <- fluidPage(
  titlePanel("AE Summary Interactive Dashboard"), # App title
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput( # user can interactively select treatment arms to show on plot
        inputId = "arm_filter", # input for treatment arm filter that reacts to user selection
        label = "Select Treatment Arm(s):",
        choices = unique(df_ae_shiny$ACTARM), # filter choices are derived from the values in ACTARM
        selected = unique(df_ae_shiny$ACTARM) # by default pre-check all boxes
      )
    ),
    mainPanel( # display output from server
      plotOutput(outputId = "standard_plot", height = "600px") # output is a plot to display
    )
  )
)

# 2. Server
server <- function(input, output) { # server accepts user input from UI, sends output back to UI to display in mainPanel
  
  # Reactive Filter
  filtered_data <- reactive({
    df_ae_shiny %>%
      filter(ACTARM %in% input$arm_filter) # return dataframe that is filtered by treatment arm based on user input
  })
  
  # Render Plot
  # outputID standard_plot will return:
  #  - blank plot with text if no treatment arm is selected
  #  - stacked bar plot with data filtered by treatment arm(s) selected by user input
  output$standard_plot <- renderPlot({
    
    # Optional safety check: If no boxes are checked, return a blank plot smoothly
    if (is.null(input$arm_filter)) {
      return(ggplot() + theme_void() + ggtitle("Please select at least one Treatment Arm."))
    }
    
    # ggplot2 code from question 2
    ggplot(
      data = filtered_data(), 
      aes(x = reorder(AESOC, N_UNIQSUBJID, FUN = sum), y = N_UNIQSUBJID, fill = AESEV)) +
      geom_bar(stat = "identity") +
      coord_flip() + 
      xlab("System Organ Class") + 
      ylab("Number of Unique Subjects") + 
      labs(
        title = "Unique Subjects per SOC and Severity Level",
        fill = "Severity"
      ) + 
      scale_fill_manual(
        values = c("#fee0d2", "#fc9272", "#de2d26"),
        breaks = c("MILD", "MODERATE", "SEVERE")
      ) + 
      theme_minimal()
    
  })
}

# ------------------
#  RUN THE APP
shinyApp(ui = ui, server = server)