# created March 7, 2026 on R v4.5.2

# ------------------
# TEAE Summary Table
# Q: Create a regulatory-compliant summary table of Treatment-Emergent Adverse Events (TEAEs)
# Input Data: pharmaverseadam::adae and pharmaverseadam::adsl.
# Requirements:
#  – Treatment-emergent AE records will have TRTEMFL == "Y".
#  – Rows: System Organ Class (AESOC) and Preferred Term (AEDECOD).
#  – Columns: Treatment groups (ACTARM).
#  – Cell Values: Subject count (n) and percentage (%).
#  – Denominator: Use the total number of subjects in the study from ADSL.
#  – Total: Include a summary
#  - Output: HTML File
# ------------------

# install and load following packages
# install.packages(c("pharmaverseadam", "tidyverse", "gtsummary", "ggplot2", "shiny"))

library(pharmaverseadam) 
library(tidyverse) 
library(gtsummary) 
library(ggplot2) 
library(shiny)

# load data from pharmaverseadam, assign to objects
df_ae <- pharmaverseadam::adae # adverse events analysis
df_sl <- pharmaverseadam::adsl # subject level analysis

#-----
# DATA EXPLORATION

# Extract the column names and their hidden "label" attributes into a new table
adae_dictionary <- tibble(
  Variable = colnames(df_ae),
  Description = sapply(df_ae, attr, "label") %>% as.character()
)
view(adae_dictionary) 

adsl_dictionary <- tibble(
  Variable = colnames(df_sl),
  Description = sapply(df_sl, attr, "label") %>% as.character()
)
view(adsl_dictionary) 

# investigate data
?pharmaverseadam::adae # adverse events linked to each subject
?pharmaverseadam::adsl # subjects of the stud(ies) with treatment, arm, etc

# number of unique subjects in each dataset
df_ae %>% summarize(Total_Unique_Subjects = n_distinct(USUBJID))
df_sl %>%  summarize(Total_Unique_Subjects = n_distinct(USUBJID))
 
# check for total number of rows for each dataset number of instances of the unique subject identifier
nrow(df_ae)
nrow(df_sl)

# check for unique StudyID for each dataset
unique_study_sl <- df_sl %>% distinct(STUDYID)
unique_study_ae <- df_ae %>% distinct(STUDYID)
unique_study_ae==unique_study_sl # same study for both datasets

# identify which variables are "subject-level" (fixed) and which are "event-level" (changing)
# i.e. which columns are different in each dataset?
common_cols <- intersect(names(df_sl), names(df_ae)) # common to both
sl_only <- setdiff(names(df_sl), names(df_ae)) # SL only
ae_only <- setdiff(names(df_ae), names(df_sl)) # AE only

# number of rows associated with the unique subject identifier in each dataset
sl_counts <- df_sl %>% count(USUBJID)
ae_counts <- df_ae %>% count(USUBJID)

# Primary System Organ Class (AESOC) 
df_ae %>% distinct(AESOC)

# Preferred Term/dictionary-derived term (AEDECOD)
df_ae %>% distinct(AEDECOD)

# preferred terms listed for each system organ class
ae_hierarchy <- df_ae %>% distinct(AESOC, AEDECOD) %>% arrange(AESOC, AEDECOD)

# distinct treatment groups 
view(df_ae %>% distinct(ACTARM)) # 3 treatment groups
view(df_sl %>% distinct(ACTARM)) # 4 treatment groups

# check for NAs: summary of NAs for critical variables
df_ae %>%
  select(USUBJID, ACTARM, AESOC, AESEV, TRTEMFL) %>% #NAs exist for TRETEMFL
  summarise(across(everything(), ~sum(is.na(.))))

df_sl %>% select(USUBJID, ACTARM)%>%
  summarise(across(everything(), ~sum(is.na(.))))

# ------
# DATA PREPARATION

# create subset data of unique subject id, System Organ Class (AESOC) Preferred Term (AEDECOD), treatment,arm, treatment adverse event flag
df_ae_trae <- df_ae %>% select(USUBJID, AESOC, AEDECOD, TRTEMFL) %>% distinct(USUBJID, AESOC, AEDECOD, TRTEMFL)

# 2. Subject-level
# create subset data of unique subjects with their treatment arm to join adverse event data; remove screen failure
df_sl_treatment<- df_sl %>% 
  filter(ACTARM %in% c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose")) %>% 
  select(USUBJID, ACTARM)

# 3. joined data
# join data by unique subject ID
df_ae_sl <- left_join(df_sl_treatment, df_ae_trae, by = "USUBJID")

# number of unique subjects for each patient group
view((df_ae_sl) %>% group_by(ACTARM) %>% summarize(N = n_distinct(USUBJID)))

# Count unique subjects by Treatment Arm and the TEAE Flag
view(df_ae_sl %>% group_by(ACTARM, TRTEMFL) %>% summarize(N = n_distinct(USUBJID)))

# replace NAs with string "NA"
# df_ae_sl <- df_ae_sl %>%mutate(TRTEMFL = replace_na(TRTEMFL, "NA"))

# count unique subjects by treatment arm, TEAE flag and AESOC
# note: cardiac disorder for placebo = 12, treatment flag = Y
view(df_ae_sl %>% group_by(ACTARM, TRTEMFL, AESOC) %>% summarize(N = n_distinct(USUBJID)))

# count unique subjects by treatment arm, TEAE flag, AESOC, and AEDECOD
# note: placebo, cardiac disorder, atrial fibrillation, treatment flag Y -> n = 1
view(df_ae_sl %>% group_by(ACTARM, TRTEMFL, AESOC, AEDECOD) %>% summarize(N = n_distinct(USUBJID)))

# -----
# CREATE SUMMARY TABLE USING gtsummary
# breakdown from data exploration:
# - columns show the total number of unique subjects in each treatment arm inclusive of all treatment flags (Yes, NAs)
# - first row shows the number of subjects that only have TRTEMFL == "Y"
# - second row and onwards - breakdown of AESOC as "header" category with TRTEMFL = Y, followed by AEDECOD
# - n = 0s are included (e.g. placebo, cardiac disorder, atrial flutter, treatment flag Y -> n = 0)
# - stratification variable needs to be a factor (i.e. by = ACTARM; ACTARM needs to be factor)
# - data is the numerator/instances; only subjects who experienced an event


# 1. Prepare the Denominator (The full population)
sl_pop_data <- df_sl_treatment %>% mutate(ACTARM = droplevels(factor(ACTARM)))

# 2. Prepare the Data (The events only)
# Filter joined dataset to strictly the records where an event occurred
ae_only_data <- df_ae_sl %>%
  filter(TRTEMFL == "Y") %>% 
  mutate(ACTARM = droplevels(factor(ACTARM)))

# 3. Build the hierarchical table
summarytable_teae <- tbl_hierarchical(
  data = ae_only_data,             # numerator for subjects where TRTEMFL=Y
  variables = c(AESOC, AEDECOD),
  by = ACTARM,
  denominator = sl_pop_data,       # denominator; full population for the N calculation
  id = USUBJID,
  overall_row = TRUE,
  # Rename first row of treatment emergent adverse events
  label = list(..ard_hierarchical_overall.. = "Treatment Emergent Adverse Events") 
)

view(summarytable_teae)

# 4. Polish table appearance (rounding of values, headers, styling)
# - all N values are whole numbers
# - first row % is rounded to the nearest whole number
# - all AESOC % is rounded to the nearest whole number
# - all AEDECOD % is rounded to the first decimal place
# - If N = 0, percentage should have no decimal (0%)

summarytable_teae <- tbl_hierarchical(
  data = ae_only_data,             # numerator for subjects where TRTEMFL=Y
  variables = c(AESOC, AEDECOD),
  by = ACTARM,
  denominator = sl_pop_data,       # denominator; full population for the N calculation
  id = USUBJID,
  overall_row = TRUE,
  digits = list(
    "..ard_hierarchical_overall.." = c(0, 0),  # 0 decimals for N, 0 for % (Whole number)
    "AESOC" = c(0, 0),                         # 0 decimals for N, 0 for % (Whole number)
    # Custom function ONLY for Preferred Terms to keep 1 decimal (but clean 0%)
    "AEDECOD" = list(0, function(x) ifelse(is.na(x), NA_character_, ifelse(x == 0, "0", sprintf("%.1f", x * 100))))                       
  ),
  # Rename first row of treatment emergent adverse events
  label = list(..ard_hierarchical_overall.. = "Treatment Emergent Adverse Events") 
)
view(summarytable_teae)

summarytable_teae_final <-summarytable_teae %>% 
  modify_indent(
    columns = label,                 # Target the text column
    rows = variable == "AEDECOD",    # Apply this specifically to the Preferred Terms
    indent = 4L                      # 4 spaces of indentation (change to 8L if you want it deeper)
  ) %>%
  modify_header(
  # Rename the first column
  label = "**System Organ Class / Preferred Term**", 
  # Update all treatment columns dynamically
  all_stat_cols() ~ "**{level}**<br>N = {n}" 
) %>%
  # Bolds the System Organ Class names
  bold_labels()
view(summarytable_teae_final)

# ----
# EXPORT 
library(gt)

# Convert and save final table export as HTML
filepath_q1 <- "/cloud/project/Question_1"
summarytable_teae_final %>% 
  as_gt() %>% gtsave(filename = "output_teae_summary_table.html", path = filepath_q1)

  