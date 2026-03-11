# created March 8, 2026 on R v4.5.2

# ------------------
# AE Severity Visualization
# Q: Develop a publication-quality bar chart visualizing the distribution of adverse events.
# Input Data: pharmaverseadam::adae.
# Requirements:
#  – X-axis: Count of unique subjects per System Organ Class per Severity. 
#     Ensure each subject is counted at most once per severity level within each SOC.
#  – Y-axis: System Organ Class term (AESOC).
#  – colour/Fill: coloured by AE Severity/Intensity (AESEV).
#  – Ordering: Bars must be stacked and ordered by increasing frequency of total subjects per SOC.
# - Tooling: Use {ggplot2}.
# ------------------
# DATA PREPARATION

# install and load following packages
# install.packages(c("pharmaverseadam", "tidyverse", "gtsummary", "ggplot2", "shiny"))

library(pharmaverseadam) 
library(tidyverse) 
library(gtsummary) 
library(ggplot2) 
library(shiny)

# load data from pharmaverseadam, assign to object
df_ae <- pharmaverseadam::adae # adverse events analysis

# prepare table for plot creation
# stacked bar chart: number of unique subjects per SOC per severity
# column 1: AESOC, column 2: severity (AESEV), column 3: unique count of unique subjects
df_ae_plot <- df_ae %>% group_by(AESOC, AESEV) %>% summarize(N_UNIQSUBJID = n_distinct(USUBJID))
view(df_ae_plot)

# convert "AESEV" variable to factor and specify level order for plot
# order of bars is top to bottom for vertical bar chart
df_ae_plot$AESEV <- factor(df_ae_plot$AESEV, levels = c("SEVERE", "MODERATE", "MILD"))

# ------------------
# CREATE VISUALIZATION: Subjects per System Organ Class (SOC) and Severity Level
#
# Logic and argument breakdown:
# 1. ggplot() & aes(): 
#    - Initializes the plot using the 'df_ae_plot' dataset.
#    - reorder(AESOC, N_UNIQSUBJID, FUN = sum): Sorts the SOC categories by the 
#      total sum of subjects across all severity levels in descending order
#    - fill = AESEV: Groups and colours the sections of the stacked bars by Severity.
# 2. geom_bar(stat = "identity"): 
#    - Instructs ggplot to map the exact numeric values from 'N_UNIQSUBJID' to 
#      the bar lengths, rather than simply counting the underlying data rows
# 3. coord_flip(): 
#    - Flips the X and Y axes to create a horizontal bar chart
# 4. xlab(), ylab(), & labs(): 
#    - modify titles of axes legend
# 5. scale_fill_manual(): 
#    - Applies a custom hex colour palette (light to dark red) to the bars
#    - used online screen colour picker tool to match assessment output
#    - breaks = reorder severity values only in legend without affecting plot
# 6. theme_minimal(): 
#    - Strips away heavy background shading and thick gridlines for a clean to matc
#      for clean output; closest match to assessment output


# stacked bar chart with multiple groups
# - number of unique subjects per SOC, coloured by AE severity
plot_ae <- ggplot(
  data=df_ae_plot, 
  aes(x=reorder(AESOC, N_UNIQSUBJID, FUN = sum), y = N_UNIQSUBJID, fill=AESEV))+ 
  geom_bar(stat="identity")+
  coord_flip()+ 
  xlab("System Organ Class")+ 
  ylab("Number of Unique Subjects")+ 
  labs(title="Unique Subjects per SOC and Severity Level",
       fill="Severity")+ 
  scale_fill_manual(values=c("#fee0d2", "#fc9272", "#de2d26"),
                    breaks=c("MILD","MODERATE","SEVERE"))+ 
  theme_minimal()
plot_ae  
     
# ------------------
# EXPORT

# export as PNG file
filepath_q2 <- "/cloud/project/Question_2"
ggsave(
  filename = "output_AE_Severity_Visualization.png",
  plot = plot_ae,
  width = 20, 
  height = 8, 
  dpi = 320,
  path=filepath_q2)
