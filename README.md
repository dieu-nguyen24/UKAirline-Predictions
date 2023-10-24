# 🛩 UK Airline EDA and Classification Predictions
## Objectives
In this project undertaken during the MSc Business Analytics programme at Lancaster University, I (1) explored the sample data of a fictional UK airline to uncover insights about the potential drivers of passenger satisfaction and (2) built classification models to predict satisfaction. All processes are done using R.
## Table of Content
1. [Dataset Used](https://github.com/dieu-nguyen24/UKAirline-Predictions#dataset-used)
2. [Data Cleaning & Pre-Processing](https://github.com/dieu-nguyen24/UKAirline-Predictions#data-pre-processing)
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
This project uses the sample of data provided by Lancaster University as part of the MSCI562 course. The dataset is of dimension 10313x23.

Details of the dataset:

Target variable
* Satisfaction: airline satisfaction level ("neutral or dissatisfied" and "satisfied")

Personal details
* Gender: (female; male)
* Typecustomer: (loyal customer; disloyal customer)
* Age: (age of each customer)
* Traveltype: (types of journeys - business travel; personal travel)
* Class: (ticket class - business; economy; eco plus)

Flight details
* Flightdistance: (flight distance of the journey in miles)
* Departdelay: (minutes of delay when departing)
* Arrivedelay: (minutes of delay when arriving)

Pre-boarding (5 - totally satisfied, 1 - totally dissatisfied)
* Easeofonlinebooking: (satisfaction level of online booking; 0:NA; 1-5)
* Timeconvenient: (satisfaction level of departure/arrival time convenience; 0:NA; 1-5)
* Gatelocation: (satisfaction level of gate location; 0:NA; 1-5)
* Onlineboarding: (satisfaction level of online boarding; 0:NA; 1-5)

Onboard (5 - totally satisfied, 1 - totally dissatisfied)
* Wifi: (satisfaction level of inflight wifi service; 0:NA; 1-5)
* Fooddrink: (satisfaction level of food & drink; 0:NA; 1-5)
* Seatcomfort: (satisfaction level of seat comfort; 0:NA; 1-5)
* Inflightentertainment: (satisfaction level of inflight entertainment; 0:NA; 1-5)
* Onboard: (satisfaction level of on-board services; 0:NA; 1-5)
* Legroom: (satisfaction level of leg room service; 0:NA; 1-5)
* Checkin: (satisfaction level of check-in service; 0:NA; 1-5)
* Inflight: (satisfaction level of inflight service; 0:NA; 1-5)
* Clean: (satisfaction level of cleanliness; 0:NA; 1-5)
## Data Cleaning & Pre-Processing
### Data Cleaning
The dataset is first examined and cleaned into a more convenient format.
```
#Import the dataset
airlinesData68 <- read_csv("airlinesData68.csv")
#Remove spaces from column names
colnames(airlinesData68) <- make.names(colnames(airlinesData68))
#Move the target variable to the first column
airlinesData68 <- airlinesData68 %>% 
  dplyr::select(satisfaction, everything())
```
Categorical variables are turned into factors. The levels of the ordinal data are assigned from lowest to highest values.
```
#Check column names 
colnames(airlinesData68)

#Turn categorical variables into factors
#Nominal
airlinesData68[, c("Gender", "Customer.Type", "Type.of.Travel")] <- lapply(airlinesData68[, c("Gender", "Customer.Type", "Type.of.Travel")], factor)

#Ordinal
airlinesData68$Class <- factor(airlinesData68$Class, levels = c("Eco","Eco Plus","Business"))
airlinesData68$satisfaction <- factor(airlinesData68$satisfaction,
                                      levels = c("neutral or dissatisfied","satisfied"))
rating_columns <- c("Inflight.wifi.service", "Departure.Arrival.time.convenient",
                    "Ease.of.Online.booking", "Gate.location", "Food.and.drink",
                    "Online.boarding", "Seat.comfort", "Inflight.entertainment",
                    "On.board.service", "Leg.room.service", "Baggage.handling",
                    "Checkin.service", "Inflight.service", "Cleanliness")
airlinesData68[, rating_columns] <- lapply(airlinesData68[, rating_columns], function(x) factor(x, levels=1:5))
```
Ratings of 0s are converted into NA values for consistency.
```
#Turn 0s into NAs
airlinesData68[, rating_columns] <- lapply(airlinesData68[, rating_columns], function(x) replace(x, x==0, NA))
```
### Data Pre-Processing
In terms of missing values, a total of 1522 NAs are present in multiple variables (Figure 1.1).
```
#Check for NAs
sum(is.na(airlinesData68))
```
```
#Snapshot of the dataset
vis_miss(airlinesData68)
```

<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/Vis_miss_raw.png" alt="Snapshot of the raw data"/>
</p>
<p align="center">Figure 1.1: Snapshot of the raw data</p>

Since NAs in service evaluation variables might come from the lack of such service on the flight, these along with the NAs in ‘Arrival Delay’ are assumed to be missing at random, and thus, the observations with these values are removed from the dataset. Also, since the minimum age permitted to travel alone for some airlines is 14 (opodo.co.uk, 2019), feedback from these minors might be biased due to the possible influence of legal guardians accompanying them on the flight. Therefore, observations from passengers under 14 are also removed. After pre-processing, the dataset is now of dimension 9153x23.
```
#Make another copy of the processed data
airlinesData68EDA <- airlinesData68

#Turn values under 14 in Age column into NAs
airlinesData68EDA$Age <- replace(airlinesData68EDA$Age, airlinesData68EDA$Age < 14, NA)

#Remove all NA values
airlinesData68noNA <- na.omit(airlinesData68EDA)
```
## Exploratory Data Analysis
### Information Values
To investigate the importance level of each variable, Information Values (IVs) are used and supported by relevant conditional probability plots.
```
y <- airlinesData68noNA$satisfaction=="satisfied"
class(y)

y <- 1*y
class(y)

airlinesData68noNA["class"] <- y

IV <- create_infotables(data=airlinesData68noNA[,-c(1)], y="class", bins=6)
IV
```

```
#Density, scatter plots
ggpairs(airlinesData68noNA, aes(color = satisfaction), columns = c("Departure.Delay.in.Minutes",
                                                                   "Arrival.Delay.in.Minutes",
                                                                   "Flight.Distance"))
```

In Table 2.1, the IVs of ‘Arrival Delay’, Departure Delay’, ‘Time convenience’ and ‘Gender’ indicate weak discriminatory power. For Delay variables, the scatter plot in Figure 2.1 displays no separability of classes. This finding contrasts with common sense since delays typically impact passenger satisfaction negatively, and so the relevance of this variable should still be considered. ‘Time convenience’, however, does not appear to be important in predicting satisfaction perhaps because this has more to do with customers’ initial flight-booking choice. Notably, Gender has the lowest IV, which suggests that this variable does not have discriminatory influence over satisfaction. Figure 2.2 supports this judgment as the portions of males and females given their satisfaction level are similar.
```
### Class Conditional Barplot - Credit: 
cc_barplot <- function(Data,x,y, freq = "condProb", main = "") {
  Y <- Data[[y]]
  X <- Data[[x]]
  
  require(ggplot2)
  if (freq == "count" | freq =="freq") {
    p <- ggplot(Data, aes(x = X, fill = Y)) + geom_bar(position = "dodge") + 
      labs(fill=y, x=x, y="count") + theme_bw() 
  } else if (freq=="relfreq") {
    
    tab <- table(Y,X)
    cl <- colSums(tab)
    for (i in 1:ncol(tab)) {
      tab[,i] <- tab[,i]/cl[i]
    }
    Y <- as.data.frame(tab)
    p <- ggplot(Y, aes(x=X, y=Freq, fill=Y)) + geom_col(position = "dodge") + 
      labs(fill=y, x=x, y="Relative Frequency") + theme_bw() +
      geom_text(aes(x=X, y=Freq+ 0.03, label=signif(Freq,2)), position=position_dodge(width=0.9))
    
  } else {
    tab <- table(Y,X)
    cl <- rowSums(tab)
    for (i in 1:nrow(tab)) {
      tab[i,] <- tab[i,]/cl[i]
    }
    Y <- as.data.frame(tab)
    p <- ggplot(Y, aes(x=X, y=Freq, fill=Y)) + geom_col(position = "dodge") + 
      labs(fill=y, x=x, y=paste0("P(",x," | ",y,")")) + theme_bw() +
      geom_text(aes(x=X, y=Freq+ 0.03, label=signif(Freq,2)), position=position_dodge(width=0.9)) 
    #ggtitle(paste("Conditional Probability of ",x,"given",y))
  }
  
  if (main != "") {
    p <- p + ggtitle(label=main) + theme(plot.title = element_text(hjust = 0.5))
  }
  print(p)
}

#Conditional Probability Bar Plot of Gender given Satisfaction
cc_barplot(Data = airlinesData68noNA, "Gender","satisfaction", freq = "condprob", main = "Conditional probability of Gender given customer satisfaction")
```
According to IVs, ‘Gate location, ‘Age’, ‘Customer type’, ‘Check-in service’ and ‘Food & drink’ have moderate predictive power over satisfaction. In Figure 2.3, even though it seems that older passengers tend to be more satisfied compared to younger passengers, the distinction between classes is not too pronounced. Moreover, individuals in similar age groups can still largely differ from each other, and so, it makes sense for ‘Age’ to have low influence over satisfaction. For ‘Gate location’, its low importance is also reasonable given how this is mostly outside of the airline’s control. In terms of ‘Customer type’, the Weights of Evidence in Figure 2.4 specify that disloyal customers are less likely to be satisfied, while loyal customers are more likely to be satisfied compared to the whole population. The WoE also suggests that satisfaction is more easily predicted when a customer is categorised as ‘disloyal’. Regarding ‘Check-in service’ and ‘Food & drink’ (Figure 2.5 and 2.6), it seems that people who are satisfied with these services are more likely to be satisfied overall and vice versa.

‘Ease of Online booking, ‘Flight distance’, ‘Inflight service’, ‘Baggage handling’, ‘Cleanliness’, ‘Onboard service’, ‘Leg room service’ and ‘Seat comfort’ have relatively strong predictive power. From the figures below, it seems that if a customer is satisfied overall, there is greater chance that they will rate these airline aspects highly. Regarding ‘Flight distance’, the scatter plot in the bottom panel of Figure 2.1 displays the separability of satisfied customers for longer distance flights.

‘Online boarding’, ‘Inflight WIFI service’, ‘Class’, ‘Type of travel’ and ‘Inflight entertainment’ have the strongest discriminatory power. Regarding ‘Online boarding’, it seems that if a person is satisfied overall, it is more probable that they have had a good experience with digital boarding. For ‘Inflight entertainment’ and ‘Inflight WIFI service’, a similar pattern can also be seen in Figures 2.14 and 2.15. The high predictive power of these variables over passenger satisfaction is reasonable considering how online boarding helps customers save time, and digital services help people pass their time more enjoyably during the flight.

For ‘Travel type’, the Weights of Evidence in Figure 2.16 suggest that, compared to the population, passengers who travel for business purposes are more likely to be satisfied, whereas those who travel for personal reasons tend to be either neutral or dissatisfied. In addition, the higher magnitude of WoE points out that satisfaction level is more predictable when the type of travel is ‘Personal’. A similar relation can also be seen in ‘Class’ (Figure 2.17). Since Business-class cabins have more premium benefits, it makes sense for Business passengers to be more likely to have higher overall enjoyment.
### Correlation Analysis
To uncover possible relations and similarities between variables, Correlation analysis is conducted. In Figure 3.1, it is notable that two variables related to Flight delays are strongly associated which is reasonable since they both carry information about the effect of delays on airline experience. Moreover, ‘Travel type’ and ‘Class’ are another pair with relatively high association. Since people who travel for work reasons are typically in Business class due to company sponsorship, while those who travel for personal reasons are more likely to be fly Economy, it makes sense for this pair to have similarities. ‘Class’ is also somewhat related to ‘Flight distance’. The reason for this could be that passengers on longer flights may be willing to pay more for a higher-class ticket.

‘Inflight service’ also appears to be positively associated with ‘Inflight entertainment’ and ‘Onboard service’. As inflight entertainment is part of services provided on the flight, and onboard service might be interpreted similarly as inflight service by passengers answering the survey, the variable ‘Inflight service’ could be redundant.
‘Cleanliness,’ ‘Food & drink’, ‘Seat comfort’ and ‘Inflight entertainment’ are other variables with positive correlations with each other. This makes sense because these factors all contribute to the overall enjoyment of the flight. However, it is argued that they do not carry the same information about ‘satisfaction’ and rather they each reflect a different aspect of inflight enjoyment.

Passengers who value inflight WIFI may also place a high importance on Online booking and boarding as suggested by the heatmap. Such correlations may indicate the level of tech-savviness of customers. In addition, as satisfaction with ‘Gate location’ improves, so does the convenience of flight timing as well as ‘Ease of Online booking’ and vice versa. The relations between these factors are sensible as they all indicate pre-flight enjoyment.
### Common Characteristics of Passengers
To find the most common characteristics among customers, MDS is used as this technique can help provide a visual representation of similarities between passengers in a low-dimensional space (Borg & Groenen, 2005). Given that this dataset contains both categorical and continuous variables, the distance metric chosen to calculate such (dis)similarities is Gower’s coefficient because this method applies suitable measures on different data types, and thus, is more robust to scale differences compared to less computationally intensive measures such as Euclidean distance (ibid.).

Notably, scaling is still used for ‘Arrival Delay’ before MDS application because its data is highly skewed and could potentially distort the outputs. A constant of 1 is added to the variable given the large number of zeros present and Log transformation is performed. The skewness of this variable is reduced from 4.62 to 0.87.

Unlike PCA, MDS does not resolve the issue of multicollinearity. Therefore, some variables which have been found to be similar with others in the previous section i.e. ‘Type of Travel’, ‘Inflight service’, ‘Departure Delay’ are removed before performing MDS. Furthermore, ‘Gender, ‘Gate location’ and ‘Time convenience’ are also removed as they do not contribute much to distinguishing between customers.

The number of dimensions to reduce to is chosen based on Stress metrics. To lessen computational complications, a random sample of 1000 values (with a random seed ‘0’ set for reproducibility) is used for the calculations of stress values for different dimensionalities. According to Figure 4.1, 2D MDS makes the most sense as Stress is lowest for two dimensions. Interpretation is also simpler in this case compared to higher dimensions.

Figure 4.2 shows the two-dimensional representation of the (dis)similarity between passengers based on their characteristics. Since three clusters are observed from the plot, K-means clustering is used to segment similar customers. Each cluster is then analysed to find the most common characteristics.

From Figure 4.3, it appears that the majority of Cluster 1 consists of younger Economy travellers who have had either neutral or subpar experience with services. The only services with generally higher ratings from this group are Baggage-handling and Check-in service. It is worth noting that if a customer feels neutral or dissatisfied, the probability of them belonging to Cluster 1 is highest compared to other clusters (Figure 4.4). This suggests that improvements to services badly rated by this segment might help to increase overall satisfaction.

Cluster 2 and Cluster 3, on the other hand, are especially similar with each other and noticeably different from Cluster 1 in several aspects (Figure 4.5 and 4.6). These two groups tend to have more Business passengers and the median age is slightly higher. Their experience with airline services is generally more satisfactory than Cluster 1, which could possibly be driven by the pricier ticket class. One observable difference between Cluster 2 and 3 is that general service satisfaction, except for ‘Ease of Online booking’, is only slightly lower for the former group as there are more 4/5 ratings compared to Cluster 3’s common 5/5 ratings.

From the general understanding of the clusters, a possible name for D1 could be ‘Price consciousness’ given the location of the clusters in Figure 4.2 and how there is a greater portion of Economy passengers in Cluster 1. However, the slight overlapping of classes among segments suggest that D1 might be more characterised by other aspects. From Figure 4.7, D1 seems to have negative relations with many variables related to onboard services. This observation combined with prior cluster analysis suggest that D1 could be viewed as ‘Inflight quality dissatisfaction’, especially since passengers who have had average to poor inflight experience are more concentrated on the right-hand side of the MDS plot, while on the left-hand side, there are more travellers with positive experience (Figure 4.8).

D2 is less clear to interpret compared to D1. LASSO regression is then performed to find the combination of variables that best explain this dimension. This method is favoured over stepwise because it is better for variable selection given the high-dimensional nature of the dataset and can avoid the risk of overfitting (James et al., 2021). From the model output in Table 4.1, it seems that people who gave 4/5 ratings for the listed onboard services are more associated with the upper area of the MDS plot, which is consistent with previous cluster analysis. One possible interpretation of D2 could be ‘Level of criticalness’ in terms of service evaluations.

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
