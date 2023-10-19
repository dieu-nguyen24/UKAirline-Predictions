# 🛩 UK Airline EDA and Classification Predictions
## Objectives
In this project, I (1) explored the data of a fictional airline in the UK to uncover insights about the potential drivers of passenger satisfaction and (2) built classification models to predict satisfaction.
## Table of Content
1. [Dataset Used](https://github.com/dieu-nguyen24/UKAirline-Predictions)
2. [Data Pre-processing](https://github.com/dieu-nguyen24/UKAirline-Predictions)
3. [Exploratory Data Analysis](https://github.com/dieu-nguyen24/UKAirline-Predictions)
4. [Model Building](https://github.com/dieu-nguyen24/UKAirline-Predictions)
5. [Performance Evaluation](https://github.com/dieu-nguyen24/UKAirline-Predictions)
6. [References](https://github.com/dieu-nguyen24/UKAirline-Predictions)
## Dataset Used
This project uses 
## Data Pre-Processing
Before further analysis, the dataset has been examined based on data quality dimensions such as Accuracy, Completeness, and Timeliness (Berthold et al., 2010).

One dimension where issues are found is Completeness. Specifically, a total of 1522 missing values are present in multiple variables (Figure 1.1). Since NAs in service evaluation variables might come from the lack of such service on the flight, these along with the NAs in ‘Arrival Delay’ are assumed to be missing at random, and thus, the observations with these values are removed from the dataset.

On a related note, since the minimum age permitted to travel alone for some airlines is 14 (opodo.co.uk, 2019), feedback from these minors might be biased due to the possible influence of legal guardians accompanying them on the flight. Therefore, observations from passengers under 14 are also removed.
## Exploratory Data Analysis
### Information Values
### Correlation Analysis
### Common Characteristics of Passengers
## Model Building
### Logistic Regression
### k-NN
### Bagging and Random Forest
## Performance Evaluation
### Expected Generalisation Performance
### TPR and TNR Trade-off
### Variable Importance
## References
