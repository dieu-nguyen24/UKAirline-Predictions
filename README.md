# 🛩 UK Airline EDA and Classification Predictions
## Objectives
In this project, I (1) explored the data of a fictional UK airline to uncover insights about the potential drivers of passenger satisfaction and (2) built classification models to predict satisfaction. All processes are done using R.
## Table of Content
1. [Dataset Used](https://github.com/dieu-nguyen24/UKAirline-Predictions#dataset-used)
2. [Data Pre-processing](https://github.com/dieu-nguyen24/UKAirline-Predictions#data-pre-processing)
3. [Exploratory Data Analysis](https://github.com/dieu-nguyen24/UKAirline-Predictions#exploratory-data-analysis)
* [Information Values](https://github.com/dieu-nguyen24/UKAirline-Predictions#information-values)
* [Correlation Analysis](https://github.com/dieu-nguyen24/UKAirline-Predictions#correlation-analysis)
* [Common Characteristics of Passengers](https://github.com/dieu-nguyen24/UKAirline-Predictions#common-characteristics-of-passengers)
4. [Model Building](https://github.com/dieu-nguyen24/UKAirline-Predictions#model-building)
* [Logistic Regression](https://github.com/dieu-nguyen24/UKAirline-Predictions#logistic-regression)
* [k-NN](https://github.com/dieu-nguyen24/UKAirline-Predictions#k-nn)
* [Bagging](https://github.com/dieu-nguyen24/UKAirline-Predictions#bagging)
* [Random Forest](https://github.com/dieu-nguyen24/UKAirline-Predictions#random-forest)
5. [Performance Evaluation](https://github.com/dieu-nguyen24/UKAirline-Predictions#performance-evaluation)
6. [References](https://github.com/dieu-nguyen24/UKAirline-Predictions#references)
## Dataset Used
This project uses 
## Data Pre-Processing
Before further analysis, the dataset has been examined based on data quality dimensions such as Accuracy, Completeness, and Timeliness (Berthold et al., 2010).
<p align="center">
  <img src="" alt="Data Quality Dimensions"/>
</p>
One dimension where issues are found is Completeness. Specifically, a total of 1522 missing values are present in multiple variables (Figure 1.1).

```
#Snapshot of the dataset
vis_miss(airlinesData68)
```

<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/Vis_miss_raw.png" alt="Snapshot of the raw data"/>
</p>
<p align="center">Figure 1.1: Snapshot of the raw data</p>

Since NAs in service evaluation variables might come from the lack of such service on the flight, these along with the NAs in ‘Arrival Delay’ are assumed to be missing at random, and thus, the observations with these values are removed from the dataset. On a related note, since the minimum age permitted to travel alone for some airlines is 14 (opodo.co.uk, 2019), feedback from these minors might be biased due to the possible influence of legal guardians accompanying them on the flight. Therefore, observations from passengers under 14 are also removed.

## Exploratory Data Analysis
### Information Values
To investigate the importance level of each variable, IVs are used and supported by relevant conditional probability plots.

In Table 2.1, the IVs of ‘Arrival Delay’, Departure Delay’, ‘Time convenience’ and ‘Gender’ indicate weak discriminatory power. For Delay variables, the scatter plot in Figure 2.1 displays no separability of classes. This finding contrasts with common sense since delays typically impact passenger satisfaction negatively (Kim & Park, 2016), and so the relevance of this variable should still be considered. ‘Time convenience’, however, does not appear to be important in predicting satisfaction perhaps because this has more to do with customers’ initial flight-booking choice. Notably, Gender has the lowest IV, which suggests that this variable does not have discriminatory influence over satisfaction. Figure 2.2 supports this judgment as the portions of males and females given their satisfaction level are similar.

According to IVs, ‘Gate location, ‘Age’, ‘Customer type’, ‘Check-in service’ and ‘Food & drink’ have moderate predictive power over satisfaction. In Figure 2.3, even though it seems that older passengers tend to be more satisfied compared to younger passengers, the distinction between classes is not too pronounced. Moreover, individuals in similar age groups can still largely differ from each other, and so, it makes sense for ‘Age’ to have low influence over satisfaction. For ‘Gate location’, its low importance is also reasonable given how this is mostly outside of the airline’s control. In terms of ‘Customer type’, the Weights of Evidence in Figure 2.4 specify that disloyal customers are less likely to be satisfied, while loyal customers are more likely to be satisfied compared to the whole population. The WoE also suggests that satisfaction is more easily predicted when a customer is categorised as ‘disloyal’. Regarding ‘Check-in service’ and ‘Food & drink’ (Figure 2.5 and 2.6), it seems that people who are satisfied with these services are more likely to be satisfied overall and vice versa.

‘Ease of Online booking, ‘Flight distance’, ‘Inflight service’, ‘Baggage handling’, ‘Cleanliness’, ‘Onboard service’, ‘Leg room service’ and ‘Seat comfort’ have relatively strong predictive power. From the figures below, it seems that if a customer is satisfied overall, there is greater chance that they will rate these airline aspects highly. Regarding ‘Flight distance’, the scatter plot in the bottom panel of Figure 2.1 displays the separability of satisfied customers for longer distance flights.

‘Online boarding’, ‘Inflight WIFI service’, ‘Class’, ‘Type of travel’ and ‘Inflight entertainment’ have the strongest discriminatory power. Regarding ‘Online boarding’, it seems that if a person is satisfied overall, it is more probable that they have had a good experience with digital boarding. For ‘Inflight entertainment’ and ‘Inflight WIFI service’, a similar pattern can also be seen in Figures 2.14 and 2.15. The high predictive power of these variables over passenger satisfaction is reasonable considering how online boarding helps customers save time, and digital services help people pass their time more enjoyably during the flight.

For ‘Travel type’, the Weights of Evidence in Figure 2.16 suggest that, compared to the population, passengers who travel for business purposes are more likely to be satisfied, whereas those who travel for personal reasons tend to be either neutral or dissatisfied. In addition, the higher magnitude of WoE points out that satisfaction level is more predictable when the type of travel is ‘Personal’. A similar relation can also be seen in ‘Class’ (Figure 2.17). Since Business-class cabins have more premium benefits, it makes sense for Business passengers to be more likely to have higher overall enjoyment.
### Correlation Analysis
### Common Characteristics of Passengers
## Model Building
### Logistic Regression
### k-NN
### Bagging
### Random Forest
## Performance Evaluation
### Expected Generalisation Performance
### TPR and TNR Trade-off
### Variable Importance
## References
