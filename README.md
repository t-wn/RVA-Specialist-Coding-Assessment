# RVA Specialist Coding Assessment

### About the Project
This repository contains the R scripts, output files, and an interactive application developed for the RVA Specialist Coding Assessment. The project utilizes clinical trial datasets (ADaM) from the `{pharmaverseadam}` package to perform data manipulation with `{tidyverse}`, generate regulatory-style summary tables with `{gtsummary}`, and create both static and interactive data visualizations with `{ggplot2}` and `{shiny}`. All scripts were produced with R version 4.5.2.

Project Link: [https://github.com/t-wn/RVA-Specialist-Coding-Assessment]

---

### Repository Structure & Folder Contents

This repository is organized into distinct folders for each assessment question. Each folder contains the necessary R script and its corresponding generated output.

#### `Question_1/`
Contains the code and output for the Treatment-Emergent Adverse Event (TEAE) summary table.

* **`question_1.R`**: R script that cleans the `adae` dataset and utilizes `{gtsummary}` to generate the formatted table.

* **`output_teae_summary_table.html`**: The final rendered HTML table.

#### `Question_2/`
Contains the code and output for the static data visualization.

* **`question_2.R`**: R script that Prepares a summarized dataset and utilizes `{ggplot2}` to create a horizontal stacked bar chart displaying the number of unique subjects per System Organ Class (SOC) and Severity Level.

* **`output_AE_Severity_Visualization.png`**: The high-resolution exported plot.

#### `Question_3/`
Contains the interactive web application.

* **`question_3.R`**: R script containing the full `{shiny}` application, which adapts the Question 2 plot into an interactive dashboard with treatment arm filtering.

### Root Directory
* **`Approach_Methodology_and_Reflections.Rmd`**: R Markdown report containing my code outputs alongside my approach, methodology, and personal reflections for the assessment.
* **`project.Rproj`**: The RStudio Project file. Reviewers should open this file first to launch the environment and ensure all relative file paths work seamlessly.
* **`README.md`**: This document, providing an overview of the project, package requirements, and instructions for the reviewer.
* **`README.html`**: The compiled HTML version of the README for easy reading directly in a web browser.

---

### Instructions for the Reviewer
To reproduce this environment and run the code:

1. Open the project in RStudio.
2. Ensure the following R packages are installed: `tidyverse`, `gtsummary`, `gt`, `shiny`, and `pharmaverseadam`.

```sh
  install.packages(c("pharmaverseadam", "tidyverse", "gtsummary", "ggplot2", "shiny"))
```
3. Run the scripts in order.
4. To view the Shiny App: Open `question_3_shiny.R` and click the "Run App" button.

---

### Assessment Questions

#### Question 1: TEAE Summary Table
Create a regulatory-compliant summary table of Treatment-Emergent Adverse Events (TEAEs) with the following requirements:

* Input Data: `{pharmaverseadam::adae}` and `{pharmaverseadam::adsl}`.
* Treatment-emergent AE records will have `TRTEMFL` == "Y".
* Rows: System Organ Class `AESOC` and Preferred Term `AEDECOD`.
* Columns: Treatment groups `ACTARM`.
* Cell Values: Subject count (n) and percentage (%).
* Denominator: Use the total number of subjects in the study from ADSL.
* Total: Include a summary
* Output: HTML File

#### Question 2: AE Severity Visualization
Develop a publication-quality bar chart visualizing the distribution of adverse events with the following requirements:

* Input Data: `{pharmaverseadam::adae}`
* X-axis: Count of unique subjects per System Organ Class per Severity. 
  * Ensure each subject is counted at most once per severity level within each SOC.
* Y-axis: System Organ Class term `AESOC`.
* Colour/Fill: coloured by AE Severity/Intensity`AESEV`.
* Ordering: Bars must be stacked and ordered by increasing frequency of total subjects per SOC.
* Tooling: Use `{ggplot2}`.

#### Question 3: Interactive R Shiny Application
Integrate the visualization from Question 2 into an interactive dashboard with the following requirements:

*  Display the bar chart from Question 2 within a Shiny UI.
*  Filter: Add a user input (e.g., `selectInput` or `checkboxGroupInput`) to filter the chart by Treatment Arm `ACTARM`
*  Reactivity: The plot must update dynamically based on the selected filter.
*  Tooling: Use the `{shiny}` framework.

---

### Authors
Scripts and Outputs: Tanny Wen (tannywen12@gmail.com, tanny.wen@roche.com)

Assessment Questions: Roche PD Data Science & Analytics

### License

Distributed under the MIT License. See `LICENSE.txt` for more information.

### Resources and Acknowledgments

* [CDISC](https://www.cdisc.org/)
* [Choose an Open Source License](https://choosealicense.com)
* [CRAN: ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)
* [CRAN: gtsummary](https://CRAN.R-project.org/package=gtsummary)
* [CRAN: pharmaverseadam](https://cran.r-project.org/web/packages/pharmaverseadam/refman/pharmaverseadam.html)
* [CRAN: shiny](https://CRAN.R-project.org/package=shiny)
* [ggplot2 Cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/data-visualization.pdf)
* [Image Color Picker](https://imagecolorpicker.com/)
* [Youtube Tutorial: Web Apps in R: Build Interactive Histogram Web Application in R | Shiny Tutorial Ep 2](https://www.youtube.com/watch?v=lC1Dk6gUbe0&list=PLtqF5YXg7GLkxx_GGXDI_EiAvkhY9olbe&index=3)

