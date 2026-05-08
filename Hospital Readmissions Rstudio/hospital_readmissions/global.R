# Check if packages installed
source("setup_project.R")

library(tidyverse)
library(shiny)
library(plotly)
library(shinydashboard)

df <- read.csv("C:/Users/aaron/Documents/RProjects_2026/Hospital Readmissions/data/hospital_readmissions_clean.csv")

# Convert numeric columns from character to numeric
df$Excess.Readmission.Ratio <- as.numeric(df$Excess.Readmission.Ratio)
df$Predicted.Readmission.Rate <- as.numeric(df$Predicted.Readmission.Rate)
df$Expected.Readmission.Rate <- as.numeric(df$Expected.Readmission.Rate)
df$Number.of.Discharges <- as.numeric(df$Number.of.Discharges)
df$Number.of.Readmissions <- as.numeric(df$Number.of.Readmissions)