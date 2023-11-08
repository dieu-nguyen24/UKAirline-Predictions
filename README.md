# 🛩 UK Airline EDA and Classification Predictions
## Objectives
This project undertaken by me during the MSc Business Analytics programme at Lancaster University has two main parts:
1. Exploring the sample data of a fictional UK airline to uncover insights about the main factors influencing passenger satisfaction.
   The questions to be addressed in this section are:
- Which variables appear to be important for the task at hand?
- Are different variables related? Which variables convey information similar to that provided in other variable(s)?
- What are the most common characteristics among the passengers?

2. Building classification models to predict whether a new customer will be satisfied given their characteristics and survey responses. The ideal model will be able to achieve the company’s goals of at least 95% in terms of Specificity (True Negative Rate) and 90% regarding Sensitivity (True Positive Rate).

All processes are done using R.
## Table of Content
1. [Dataset Used](https://github.com/dieu-nguyen24/UKAirline-Predictions#dataset-used)
2. [Data Cleaning & Pre-Processing](https://github.com/dieu-nguyen24/UKAirline-Predictions#data-pre-processing)
3. [Exploratory Data Analysis](https://github.com/dieu-nguyen24/UKAirline-Predictions#exploratory-data-analysis)
* [Information Values](https://github.com/dieu-nguyen24/UKAirline-Predictions#information-values)
* [Correlation Analysis](https://github.com/dieu-nguyen24/UKAirline-Predictions#correlation-analysis)
* [Common Characteristics of Passengers](https://github.com/dieu-nguyen24/UKAirline-Predictions#common-characteristics-of-passengers)
* [Conclusions from EDA](https://github.com/dieu-nguyen24/UKAirline-Predictions#conclusions-from-eda)
4. [Model Building](https://github.com/dieu-nguyen24/UKAirline-Predictions#model-building)
* [Logistic Regression](https://github.com/dieu-nguyen24/UKAirline-Predictions#logistic-regression)
* [k-NN](https://github.com/dieu-nguyen24/UKAirline-Predictions#k-nn)
* [Tree-Based](https://github.com/dieu-nguyen24/UKAirline-Predictions#tree-based)
* [Conclusions from Modelling](https://github.com/dieu-nguyen24/UKAirline-Predictions#conclusions-from-modelling)
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
## Libraries used
```
library(readr)
library(greybox)
library(lattice)
library(Information)
library(MASS)
library(ggplot2)
library(lessR)
library(corrplot)
library(dplyr)
library(plotrix)
library(cluster)
library(GGally)
library(mclust)
library(ISLR2)
library(leaps)
library(glmnet)
library(naniar)
library(visdat)
library(Hmisc)
library(moments)
library(stringr)
library(caret)
library(ipred)
library(themis)
library(pROC)
library(randomForest)
```
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
#Add a binary class variable
y <- airlinesData68noNA$satisfaction=="satisfied"
class(y)

y <- 1*y
class(y)

airlinesData68noNA["class"] <- y

#Extract WoE and IV values
IV <- create_infotables(data=airlinesData68noNA[,-c(1)], y="class", bins=6)
IV
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/IVs.png" alt="IVs" width="400"/>
</p>
<p align="center">Figure 2.1: Information Values of predictors</p>

```
#Density, scatter plots
ggpairs(airlinesData68noNA, aes(color = satisfaction), columns = c("Departure.Delay.in.Minutes",
                                                                   "Arrival.Delay.in.Minutes",
                                                                   "Flight.Distance"))
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ggpairs_density_scatter.png" alt="Density and Scatter plots" width="600"/>
</p>
<p align="center">Figure 2.2: Density and Scatter plots</p>

In Figure 2.1, the IVs of ‘Arrival Delay’, Departure Delay’, ‘Time convenience’ and ‘Gender’ indicate weak discriminatory power. For Delay variables, the scatter plot in Figure 2.2 displays no separability of classes. This finding contrasts with common sense since delays typically impact passenger satisfaction negatively, and so the relevance of this variable should still be considered. ‘Time convenience’, however, does not appear to be important in predicting satisfaction perhaps because this has more to do with customers’ initial flight-booking choice. Notably, Gender has the lowest IV, which suggests that this variable does not have discriminatory influence over satisfaction. Figure 2.3 supports this judgment as the portions of males and females given their satisfaction level are similar.
```
### Function to create Class Conditional Barplot - Credit: Ivan Svetunkov, Kandrika Pritularga
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
cc_barplot(Data = airlinesData68noNA, "Gender","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Gender given customer satisfaction")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbarplot_gender.png" alt="Conditional Probability Bar Plot Gender" width="500"/>
</p>
<p align="center">Figure 2.3</p>

According to IVs, ‘Gate location, ‘Age’, ‘Customer type’, ‘Check-in service’ and ‘Food & drink’ have moderate predictive power over satisfaction. In Figure 2.4, even though it seems that older passengers tend to be more satisfied compared to younger passengers, the distinction between classes is not too pronounced. Moreover, individuals in similar age groups can still largely differ from each other, and so, it makes sense for ‘Age’ to have low influence over satisfaction. For ‘Gate location’, its low importance is also reasonable given how this is mostly outside of the airline’s control. In terms of ‘Customer type’, the Weights of Evidence in Figure 2.5 specify that disloyal customers are less likely to be satisfied, while loyal customers are more likely to be satisfied compared to the whole population. The WoE also suggests that satisfaction is more easily predicted when a customer is categorised as ‘disloyal’. Regarding ‘Check-in service’ and ‘Food & drink’ (Figure 2.6 and 2.7), it seems that people who are satisfied with these services are more likely to be satisfied overall and vice versa.
```
#Conditional Density Plot of Age given Satisfaction
densityplot(~Age, data=airlinesData68noNA, groups = satisfaction, 
            auto.key = TRUE, main = "Conditional density P(Age|Satisfaction)")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/densityage.png" alt="Conditional Density" width="500"/>
</p>
<p align="center">Figure 2.4</p>

```
#Plot WoE values of all independent variables
lapply(colnames(airlinesData68noNA[,-c(1,24)]), function(variable) plot_infotables(IV, variable))
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/woe_custype.png" alt="WoE Customer Type" width="400"/>
</p>
<p align="center">Figure 2.5: WoE of Customer Type</p>

<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/woecheckin.png" alt="WoE of Checkin Service" width="400"/>
</p>
<p align="center">Figure 2.6: WoE of Checkin Service</p>

<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/woefooddrink.png" alt="WoE of Food and Drink" width="400"/>
</p>
<p align="center">Figure 2.7: WoE of Food & Drink</p>

‘Ease of Online booking, ‘Flight distance’, ‘Inflight service’, ‘Baggage handling’, ‘Cleanliness’, ‘Onboard service’, ‘Leg room service’ and ‘Seat comfort’ have relatively strong predictive power. From the figures below, it seems that if a customer is satisfied overall, there is greater chance that they will rate these airline aspects highly. Regarding ‘Flight distance’, the scatter plot in the bottom panel of Figure 2.2 displays the separability of satisfied customers for longer distance flights.
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_easeonlinebook.png" alt="Conditional Bar Plot Ease of Online Booking" width="500"/>
</p>
<p align="center">Figure 2.8</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_seatcomfort.png" alt="Conditional Bar Plot Seat Comfort" width="500"/>
</p>
<p align="center">Figure 2.9</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_onboard.png" alt="Conditional Bar Plot Onboard Service" width="500"/>
</p>
<p align="center">Figure 2.10</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_clean.png" alt="Conditional Bar Plot Cleanliness" width="500"/>
</p>
<p align="center">Figure 2.11</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_baggage.png" alt="Conditional Bar Plot Baggage Handling" width="500"/>
</p>
<p align="center">Figure 2.12</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_inflight.png" alt="Conditional Bar Plot Inflight Service" width="500"/>
</p>
<p align="center">Figure 2.13</p>

‘Online boarding’, ‘Inflight WIFI service’, ‘Class’, ‘Type of travel’ and ‘Inflight entertainment’ have the strongest discriminatory power. Regarding ‘Online boarding’, it seems that if a person is satisfied overall, it is more probable that they have had a good experience with digital boarding. For ‘Inflight entertainment’ and ‘Inflight WIFI service’, a similar pattern can also be seen in Figures 2.15 and 2.16. The high predictive power of these variables over passenger satisfaction is reasonable considering how online boarding helps customers save time, and digital services help people pass their time more enjoyably during the flight.
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_onlineboard.png" alt="Conditional Bar Plot Online Boarding" width="500"/>
</p>
<p align="center">Figure 2.14</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_inflightent.png" alt="Conditional Bar Plot Inflight Entertainment" width="500"/>
</p>
<p align="center">Figure 2.15</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbar_inflightwifi.png" alt="Conditional Bar Plot Inflight WIFI" width="500"/>
</p>
<p align="center">Figure 2.16</p>
For ‘Travel type’, the Weights of Evidence in Figure 2.17 suggest that, compared to the population, passengers who travel for business purposes are more likely to be satisfied, whereas those who travel for personal reasons tend to be either neutral or dissatisfied. In addition, the higher magnitude of WoE points out that satisfaction level is more predictable when the type of travel is ‘Personal’. A similar relation can also be seen in ‘Class’ (Figure 2.18). Since Business-class cabins have more premium benefits, it makes sense for Business passengers to be more likely to have higher overall enjoyment.

<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/woetypetravel.png" alt="WoE of Travel Type" width="400"/>
</p>
<p align="center">Figure 2.17: WoE of Travel Type</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/woeclass.png" alt="WoE of Class" width="400"/>
</p>
<p align="center">Figure 2.18: WoE of Ticket Class</p>

### Correlation Analysis
To uncover possible relations and similarities between variables, Correlation analysis is conducted.
```
#Correlation plot, removing the binary class variable previously created
corrplot(association(airlinesData68noNA[,-24])$value)
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/corrplot.png" alt="Association Heatmap" width=800/>
</p>
<p align="center">Figure 3.1: Association Heatmap</p>
In Figure 3.1, it is notable that two variables related to Flight delays are strongly associated which is reasonable since they both carry information about the effect of delays on airline experience. Moreover, ‘Travel type’ and ‘Class’ are another pair with relatively high association. Since people who travel for work reasons are typically in Business class due to company sponsorship, while those who travel for personal reasons are more likely to fly Economy, it makes sense for this pair to have similarities. ‘Class’ is also somewhat related to ‘Flight distance’. The reason for this could be that passengers on longer flights may be willing to pay more for a higher-class ticket.

‘Inflight service’ also appears to be positively associated with ‘Inflight entertainment’ and ‘Onboard service’. As inflight entertainment is part of services provided on the flight, and onboard service might be interpreted similarly as inflight service by passengers answering the survey, the variable ‘Inflight service’ could be redundant.

‘Cleanliness,’ ‘Food & drink’, ‘Seat comfort’ and ‘Inflight entertainment’ are other variables with positive correlations with each other. This makes sense because these factors all contribute to the overall enjoyment of the flight. However, it is argued that they do not carry the same information about ‘satisfaction’ and rather they each reflect a different aspect of inflight enjoyment.

Passengers who value inflight WIFI may also place a high importance on Online booking and boarding as suggested by the heatmap. Such correlations may indicate the level of tech-savviness of customers. In addition, as satisfaction with ‘Gate location’ improves, so does the convenience of flight timing as well as ‘Ease of Online booking’ and vice versa. The relations between these factors are sensible as they all indicate pre-flight enjoyment.
### Common Characteristics of Passengers
To find the most common characteristics among customers, MDS is used as this technique can help provide a visual representation of similarities between passengers in a low-dimensional space (Borg & Groenen, 2005). Given that this dataset contains both categorical and continuous variables, the distance metric chosen to calculate such (dis)similarities is Gower’s coefficient because this method applies suitable measures on different data types, and thus, is more robust to scale differences compared to less computationally intensive measures such as Euclidean distance (ibid.).

Notably, scaling is still used for ‘Arrival Delay’ before MDS application because its data is highly skewed and could potentially distort the outputs. A constant of 1 is added to the variable given the large number of zeros present and Log transformation is performed. The skewness of this variable is reduced from 4.62 to 0.87.
```
#Log transform Arrival Delay variable
airlinesData68noNA$Arrival.Delay.tf <- airlinesData68noNA$Arrival.Delay.in.Minutes + 1
airlinesData68noNA$Arrival.Delay.tf <- log10(airlinesData68noNA$Arrival.Delay.tf)

#Compare the skewness of original and transformed Arrival Delay variable
skewness(airlinesData68noNA$Arrival.Delay.tf)
skewness(airlinesData68noNA$Arrival.Delay.in.Minutes)
```
Unlike PCA, MDS does not resolve the issue of multicollinearity. Therefore, some variables which have been found to be similar with others in the previous section i.e. ‘Type of Travel’, ‘Inflight service’, ‘Departure Delay’ are removed before performing MDS. Furthermore, ‘Gender, ‘Gate location’ and ‘Time convenience’ are also removed as they do not contribute much to distinguishing between customers.
```
#Remove chosen variables
cols_torm <- c("satisfaction","Type.of.Travel","Inflight.service",
   "Departure.Delay.in.Minutes", "Gender",
   "Gate.location","Departure.Arrival.time.convenient", "Arrival.Delay.in.Minutes", "class")

airline_transformed <- airlinesData68noNA[,-which(names(airlinesData68noNA) %in% cols_torm)]
```
The number of dimensions to reduce to is chosen based on Stress metrics. To lessen computational complications, a random sample of 1000 values (with a random seed ‘0’ set for reproducibility) is used for the calculations of stress values for different dimensionalities.
```
#Take a sample of 1000 observations
set.seed(0)
airlinesData68_sample <- sample_n(airline_transformed, 1000)
```
According to Figure 4.1, 2D MDS makes the most sense as Stress is lowest for two dimensions. Interpretation is also simpler in this case compared to higher dimensions.
```
#Dissimilarity Matrix
airlinesData68DissimMatrix <- daisy(airlinesData68_sample, metric = "gower")

#Stress plot
#Number of original dimensions
nDim <- ncol(airlinesData68_sample)
airlinesData68Stress <- vector("numeric", nDim)

for (i in 1:nDim){
  #Do MDS
  airlinesData68MDSTest <- cmdscale(airlinesData68DissimMatrix, k=i)
  #Produce dissimilarities matrix for the new dimensions
  airlinesData68MDSDist <- daisy(airlinesData68MDSTest, "gower")
  #Calculate stress metrics
  airlinesData68Stress[i] <- sqrt(sum((airlinesData68DissimMatrix - 
                                         airlinesData68MDSDist)^2)/sum(airlinesData68DissimMatrix^2))
}

plot(airlinesData68Stress, main="Stress Diagram", xlab="Dimensions", ylab = "Stress")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/stressdiagram.png" alt="Stress Diagram" width=600/>
</p>
<p align="center">Figure 4.1: Stress Diagram</p>

MDS with 2 dimensions is then performed on all data.
```
#Generate Dissimilarity Matrix using all data
distgower <- daisy(airline_transformed, metric = "gower")

#Perform MDS with 2 dimensions
allMDS <- cmdscale(distgower, k=2)

#Change column names to D1 (dimension 1) and D2 (dimension 2)
colnames(allMDS) <- c("D1", "D2")

#Visualise the 2 dimensions
plot(allMDS, main = "MDS data", xlim = c(-0.4, 0.5), ylim=c(-0.5, 0.4))
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/MDS.png" alt="MDS" width=600/>
</p>
<p align="center">Figure 4.2</p>

Figure 4.2 shows the two-dimensional representation of the (dis)similarity between passengers based on their characteristics. Since three clusters are observed from the plot, K-means clustering is used to segment similar customers (Figure 4.3).

```
#Add the 2 dimensions to the processed data
airlinesData68New <- cbind(as.data.frame(allMDS), airlinesData68noNA)

#Perform K-means clustering
kmeans <- kmeans(airlinesData68New[,c(1,2)], centers=3)
cluster_assignments <- factor(kmeans$cluster)

#Add the cluster assignments to the processed data
airlinesData68New$clusters <- cluster_assignments

#Visualise the MDS data after segmented into 3 clusters
qplot(D1, D2, colour = airlinesData68New$clusters, 
      data = airlinesData68New[,c(1,2)]) + scale_colour_discrete("Clusters")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/MDSclusters.png" alt="MDSclusters" width=600/>
</p>
<p align="center">Figure 4.3: MDS plot with passengers divided into clusters</p>

Each cluster is then analysed to find the most common characteristics. From Figure 4.4, it appears that the majority of Cluster 1 consists of younger Economy travellers who have had either neutral or subpar experience with services. The only services with generally higher ratings from this group are Baggage-handling and Check-in service. It is worth noting that if a customer feels neutral or dissatisfied, the probability of them belonging to Cluster 1 is highest compared to other clusters (Figure 4.5). This suggests that improvements to services badly rated by this segment might help to increase overall satisfaction.
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/Cluster1.png" alt="C1" width=700/>
</p>
<p align="center">Figure 4.4: Snapshot of Cluster 1’s characteristics</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ccbarplot_Clusters.png" alt="C1 Barplot" width=500/>
</p>
<p align="center">Figure 4.5</p>

Cluster 2 and Cluster 3, on the other hand, are especially similar with each other and noticeably different from Cluster 1 in several aspects (Figure 4.6 and 4.7). These two groups tend to have more Business passengers and the median age is slightly higher. Their experience with airline services is generally more satisfactory than Cluster 1, which could possibly be driven by the pricier ticket class. One observable difference between Cluster 2 and 3 is that general service satisfaction, except for ‘Ease of Online booking’, is only slightly lower for the former group as there are more 4/5 ratings compared to Cluster 3’s common 5/5 ratings.
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/Cluster2.png" alt="C2" width=700/>
</p>
<p align="center">Figure 4.6: Snapshot of Cluster 2's characteristics</p>
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/Cluster2.png" alt="C3" width=700/>
</p>
<p align="center">Figure 4.7: Snapshot of Cluster 3’s characteristics</p>

From the general understanding of the clusters, a possible name for D1 could be ‘Price consciousness’ given the location of the clusters in Figure 4.2 and how there is a greater portion of Economy passengers in Cluster 1. However, the slight overlapping of classes among segments suggest that D1 might be more characterised by other aspects. From Figure 4.8, D1 seems to have negative relations with many variables related to onboard services. This observation combined with prior cluster analysis suggest that D1 could be viewed as ‘Inflight quality dissatisfaction’, especially since passengers who have had average to poor inflight experience are more concentrated on the right-hand side of the MDS plot, while on the left-hand side, there are more travellers with positive experience (Figure 4.9).
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/spreadplot.png" alt="Spread"/>
</p>
<p align="center">Figure 4.8: Spread Matrix</p>
<p align="center">
  <table>
    <tr>
      <td> <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/int.ent.sep.png"  alt="1"></td>
      <td><img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/clean.sep.png" alt="2" ></td>
     </tr> 
     <tr>
        <td><img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/fooddrink.sep.png" alt="3"></td>
        <td><img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/seat.sep.png" align="right" alt="4"></td>
    </tr>
  </table>
<p align="center">Figure 4.9: Separability of ratings for different inflight aspects</p>

D2 is less clear to interpret compared to D1. LASSO regression is then performed to find the combination of variables that best explain this dimension. This method is favoured over stepwise because it is better for variable selection given the high-dimensional nature of the dataset and can avoid the risk of overfitting (James et al., 2021). From the model output in Table 4.1, it seems that people who gave 4/5 ratings for the listed onboard services are more associated with the upper area of the MDS plot, which is consistent with previous cluster analysis. One possible interpretation of D2 could be ‘Level of criticalness’ in terms of service evaluations.
```
#LASSO D2
x <- model.matrix(D2~., airlinesData68New[,-c(3,24,26:28)])[, -c(1,2)]
y <- airlinesData68New$D2

set.seed(1)

#split the data
random.id <- sample(1:nrow(x))
train <- sample(random.id, nrow(x)*0.80) # 80% of the data is the training set 
test <- random.id[-train]
y.test <- y[test]

grid <- 10^seq(10, -2, length = 100) #grid to tune lambda

# estimate lasso regression for each lambda
lasso.fit.d2 <- glmnet(x[train,], y[train], alpha = 1,
                    lambda = grid)
set.seed(1)
foldid.d2 <- sample(1:10, size = length(train), replace = TRUE)
print(foldid.d2)

#perform Cross validation
lasso.cv.out <- cv.glmnet(x[train,], y[train], alpha = 1,
                          foldid.d2 = foldid.d2, nfolds = 10)

lasso.bestlam <- lasso.cv.out$lambda.min
print(lasso.bestlam)

lasso.coef.min.d2 <- predict(lasso.fit, type = "coefficients",
                          s = lasso.bestlam)
print(lasso.coef.min.d2)
```
| Variable                   | Coefficient  |
|----------------------------|--------------|
| (Intercept)                | 0.002326151  |
| Inflight.wifi.service4     | 0.028317078  |
| Food.and.drink4            | 0.033312829  |
| Food.and.drink5            | -0.033345533 |
| Online.boarding4           | 0.017492974  |
| Online.boarding5           | -0.022838466 |
| Seat.comfort4              | 0.029712154  |
| Seat.comfort5              | -0.045635271 |
| Inflight.entertainment4    | 0.077139192  |
| Inflight.entertainment5    | -0.09074369  |
| On.board.service4          | 0.021729611  |
| On.board.service5          | -0.036048701 |
| Leg.room.service4          | 0.009233937  |
| Leg.room.service5          | -0.028928734 |
| Baggage.handling4          | 0.022832954  |
| Baggage.handling5          | -0.043801956 |
| Cleanliness4               | 0.035958715  |
| Cleanliness5               | -0.038940208  |

Table 4.1: Summary of LASSO regression model

### Conclusions from EDA
- The variables with the strongest predictive power over passenger satisfaction are ‘Online boarding’, ‘Class’ and those that contribute toward overall inflight enjoyment such as ‘Inflight WIFI service’, ‘Inflight entertainment’ and ‘Seat comfort’.
- Regarding the relations between variables, pairs of variables that convey similar information with respect to the target variable are ‘Arrival vs. Departure Delay’ and ‘Class’ vs. ‘Type of Travel’. ‘Inflight service’ has also been found to be quite redundant. Multicollinearity could be a problem for the final task of building a predictive model if such pairs are not handled properly.
- Three similar groups of customers are detected from the use of MDS and clustering. For one segment, the most common characteristics can be viewed as the tendency to travel in Economy class and having lower inflight enjoyment. The other two are characterised by their more premium ticket class and higher level of inflight satisfaction.
- To increase overall satisfaction, it is recommended to focus on improving the mentioned inflight services. More attention should also be paid to the segment of Economy passengers.

## Model Building
The data used in this part has been pre-processed according to the findings from the EDA part. The variables Gender, Time convenience, and Departure delay are excluded either due to their low predictive power or high correlation with another variable. To ensure comparability, the numeric variables (Age, Flight distance, and Arrival delay) are scaled using the min-max approach, and categorical variables (Customer type, Class, service ratings) are transformed to be sets of dummy variables. The two classes ‘satisfied’ and ‘neutral or dissatisfied’ are changed to “Yes” and “No” respectively for ease of code manipulation in R.
```
#Pre-process data
vars.to.rm <- c("Gender","Departure.Arrival.time.convenient",
                "Departure.Delay.in.Minutes","Arrival.Delay.tf","class")
airlinetf <- airlinesData68noNA[,-which(names(airlinesData68noNA) %in% vars.to.rm)]

#Categorical variables transformed into sets of dummy variables
airlineScaled <- cbind(satisfaction=airlinetf$satisfaction,
                       as.data.frame(model.matrix(~.-satisfaction,airlinetf)[,-1]))

#Min-max scaling
airlineScaled[, c("Flight.Distance","Arrival.Delay.in.Minutes", "Age")] <- lapply(airlineScaled[, c("Flight.Distance","Arrival.Delay.in.Minutes", "Age")], function(x) (x - min(x)) / (max(x) - min(x)))

#Simplify classes to Yes and No
airlineScaled$satisfaction <- factor(ifelse(airlineScaled$satisfaction=="satisfied","Yes","No"))

#Make column names valid
colnames(airlineScaled) <- make.names(colnames(airlineScaled))

# Make sure that all variables are scaled correctly
summary(airlineScaled)
```

For all classifiers below, the data is split into train and test sets with the 75:25 ratio and a random seed (10) set for reproducibility in R. 
```
# Set a random seed for reproducibility
set.seed(10)

# All observations used in this workshop
obsAll <- nrow(airlineScaled)

# Split the data to 75%/25%
trainSet <- sample(1:obsAll, round(0.75*obsAll))
testSet <- (1:obsAll)[!(1:obsAll %in% trainSet)]
```

Most models are trained on the training set using k-fold cross-validation where k is 10, which is chosen to keep a balance between bias and variance. The seed used for model training is 41. Finally, since there is only moderate class imbalance (Figure 5.1), resampling techniques to artificially balance the data like SMOTE are not used.
```
#Class imbalance plot
fg <- airlinetf %>%
  count(satisfaction) %>%
  mutate(
    perc = round(proportions(n) * 100, 1),
    res = str_c(n, "(", perc, ")%"),
    satisfaction = as.factor(satisfaction)
  )

ggplot(fg, aes(satisfaction, n, fill = satisfaction)) +
  geom_col() +
  geom_text(aes(label = res), vjust = -0.3) + ggtitle("Value counts of Target variable") +
  labs(y="Count")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/classimbalance.png" alt="Class balance" width=800/>
</p>
<p align="center">Figure 5.1: Class balance</p>

### Logistic Regression
The first multiple logistic regression model proposed has been created by first using the shrinkage method LASSO to select the most relevant variables from the pre-processed dataset. This model uses the hyper-parameter 𝜆 that best minimises Binomial Deviance, which has been found through 10-fold cross-validation. 
```
#LASSO for Logit
grid <- 10^seq(10, -2, length = 100)

lasso.fit <- glmnet(airlineScaled[trainSet,-1], airlineScaled[trainSet,1], alpha = 1,lambda = grid,family="binomial")

set.seed(1)
foldid <- sample(1:10, size = length(trainSet), replace = TRUE)
print(foldid)

lasso.cv.out <- cv.glmnet(as.matrix(airlineScaled[trainSet,-1]), as.matrix(airlineScaled[trainSet,1]), alpha = 1,foldid = foldid, nfolds = 10,family="binomial")

lasso.bestlam <- lasso.cv.out$lambda.min

lasso.coef.min <- predict(lasso.fit, type = "coefficients",s = lasso.bestlam)

print(lasso.coef.min)
```

Table 5.1 presents the outputs after applying LASSO regression. It appears that the probability of someone being a satisfied customer increases when they are either loyal to the brand, have flown in Business class, or have rated certain airline services highly, given that other predictors are held constant. On the other hand, this probability decreases if they have faced delays, rated services poorly, or have travelled for personal reasons. This aligns with the findings from the EDA.

| Feature                        | Coefficient |
|--------------------------------|-------------|
| Intercept                       | -3.89363026 |
| Customer.Type: Loyal.Customer   | 2.04760511  |
| Type.of.Travel: Personal.Travel | -2.85260439 |
| Class: Business                 | 0.69175085  |
| Inflight.wifi.service: 2        | -0.03753753 |
| Inflight.wifi.service: 4        | 0.71721679  |
| Inflight.wifi.service: 5        | 3.49051151  |
| Gate.location: 5                | -0.28279392 |
| Online.boarding: 3              | -0.30089333 |
| Online.boarding: 4              | 1.20216516  |
| Online.boarding: 5              | 2.12646627  |
| Seat.comfort: 3                | -0.16634124 |
| Seat.comfort: 5                | 0.36095349  |
| Inflight.entertainment: 4       | 0.51724818  |
| On.board.service: 4            | 0.11840297  |
| On.board.service: 5            | 0.52970474  |
| Leg.room.service: 4            | 0.80656275  |
| Leg.room.service: 5            | 0.84231757  |
| Baggage.handling: 3            | -0.40370598 |
| Baggage.handling: 5            | 0.44077277  |
| Checkin.service: 2             | -0.22219195 |
| Checkin.service: 5             | 0.42751915  |
| Inflight.service: 3            | -0.12849457 |
| Inflight.service: 5            | 0.48689996  |
| Cleanliness: 5                | 0.09553912  |
| Arrival.Delay.in.Minutes        | -0.45926946 |

Table 5.1: Coefficients of the Logistic LASSO Regression Model

Another candidate is the Logistic ‘Sink’ regression model which includes all variables in the pre-processed dataset. Since variable selection has already been done based on the EDA to avoid multicollinearity, it makes sense to also include this model.
```
#SINK Logit
SINKlogit <- glm(satisfaction ~ ., 
                   data=airlineScaled,
                   subset=trainSet,family = binomial)
summary(SINKlogit)
```

### k-NN
To tune the k that performs best in terms of ROC, cross-validation on the train set with 10 folds and 3 repetitions for 10 k values has been performed. It has been found that this measure is highest when k is equal to 17 (Figure 5.2).
```
#KNN
# Set seed for reproducibility
set.seed(41)
# Control for cross validation
TrainControl <- trainControl(method="repeatedcv", number=10,repeats=3, classProbs=TRUE,summaryFunction=twoClassSummary)

set.seed(41)
knnTrain <- train(satisfaction~., 
                   data=airlineScaled, method="knn",preProcess="scale",
                   subset=trainSet,trControl = TrainControl,metric="ROC", tuneLength=10)

plot(knnTrain, main="ROC at different values of k")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ROCknn.png" alt="ROC knn" width=600/>
</p>
<p align="center">Figure 5.2: ROC values at different k neighbours</p>

However, 17-NN does not seem to meet the company’s goal regarding Sensitivity and Specificity according to Table 5.2. This is also true for other values of k, except for 5, 7, 9, and 11 in terms of Sensitivity.

| k   | ROC         | Sen         | Spec        |
| --- | ----------- | ----------- | ----------- |
| 5   | 0.9657098   | 0.9010711   | 0.9365571   |
| 7   | 0.9695745   | 0.9021863   | 0.9357854   |
| 9   | 0.9711099   | 0.9011803   | 0.9349276   |
| 11  | 0.9715204   | 0.9008447   | 0.9353561   |
| 13  | 0.9721018   | 0.8989447   | 0.9331253   |
| 15  | 0.9722055   | 0.8986102   | 0.9326087   |
| 17  | 0.9723954   | 0.8969342   | 0.9296036   |
| 19  | 0.972067    | 0.8941386   | 0.9292615   |
| 21  | 0.9716033   | 0.8912321   | 0.9275433   |
| 23  | 0.9717416   | 0.8915681   | 0.9272851   |

Table 5.2: Cross-validation results for different values of k

### Tree-Based
In the development of Tree-based models, Decision Tree, Bagging, and Random Forest (RF) have been attempted. However, due to its lower accuracy and lack of robustness by nature (James et al., 2021), the details of the Decision Tree model are not discussed in this report.
Similar to K-NN, the two ensemble approaches have been trained through cross-validation with 10 folds and 3 repetitions. Tables 1.3 and 1.4 display the training outputs. It is observed that the ROC value is highest for RF when the number of variables tried at each split (mtry) is 30. This final RF model also slightly outperforms Bagging regarding ROC, Sensitivity, and Specificity on the training set.
```
#Train Bagging model
set.seed(41)
DTBagTrain <- train(satisfaction~., data=airlineScaled[trainSet,],method="treebag",trControl=TrainControl,metric="ROC")

#Train Random Forest model
set.seed(41)
RFTrain <- train(satisfaction~., data=airlineScaled[trainSet,],method="rf",trControl=TrainControl,metric="ROC")
```

| ROC         | Sen         | Spec        |
| ----------- | ----------- | ----------- |
| 0.9844468   | 0.9274502   | 0.9529528   |

Table 5.3: Bagging’s resampling results


| mtry   | ROC         | Sen         | Spec        |
| --- | ----------- | ----------- | ----------- |
| 2   | 0.9766876   | 0.8807221   | 0.9640317   |
| 30   | 0.9903344   | 0.9333752   | 0.9668617   |
| 59   | 0.9875409   | 0.9320337   | 0.9557843   |

Table 5.4: RF’s resampling results across tuning parameters

## Performance Evaluation
For finding the model that most accurately predicts customer satisfaction for the company, the above-mentioned models are then evaluated and compared based on their performances on the same test set.
### Expected Generalisation Performance
```
draw_confusion_matrix <- function(cm,title) {
  
  layout(matrix(c(1,1,2)))
  par(mar=c(2,2,2,2))
  plot(c(100, 345), c(300, 450), type = "n", xlab="", ylab="", xaxt='n', yaxt='n')
  title(paste0(toupper(title), "'S CONFUSION MATRIX"), cex.main=2)
  
  # create the matrix 
  rect(150, 430, 240, 370, col='#3F97D0')
  text(195, 435, 'No', cex=1.2)
  rect(250, 430, 340, 370, col='#F7AD50')
  text(295, 435, 'Yes', cex=1.2)
  text(125, 370, 'Predicted', cex=1.3, srt=90, font=2)
  text(245, 450, 'Reference', cex=1.3, font=2)
  rect(150, 305, 240, 365, col='#F7AD50')
  rect(250, 305, 340, 365, col='#3F97D0')
  text(140, 400, 'No', cex=1.2, srt=90)
  text(140, 335, 'Yes', cex=1.2, srt=90)
  
  # add in the cm results 
  res <- as.numeric(cm$table)
  text(195, 400, res[1], cex=1.6, font=2, col='white')
  text(195, 335, res[2], cex=1.6, font=2, col='white')
  text(295, 400, res[3], cex=1.6, font=2, col='white')
  text(295, 335, res[4], cex=1.6, font=2, col='white')
  
  # add in the specifics 
  plot(c(100, 0), c(100, 0), type = "n", xlab="", ylab="", main = "DETAILS", xaxt='n', yaxt='n')
  text(5, 85, names(cm$byClass[1]), cex=1.2, font=2)
  text(5, 70, round(as.numeric(cm$byClass[1]), 3), cex=1.2)
  text(20, 85, names(cm$byClass[2]), cex=1.2, font=2)
  text(20, 70, round(as.numeric(cm$byClass[2]), 3), cex=1.2)
  text(40, 85, names(cm$byClass[5]), cex=1.2, font=2)
  text(40, 70, round(as.numeric(cm$byClass[5]), 3), cex=1.2)
  text(60, 85, names(cm$byClass[6]), cex=1.2, font=2)
  text(60, 70, round(as.numeric(cm$byClass[6]), 3), cex=1.2)
  text(75, 85, names(cm$byClass[7]), cex=1.2, font=2)
  text(75, 70, round(as.numeric(cm$byClass[7]), 3), cex=1.2)
  text(90, 85, names(cm$byClass[11]), cex=1.2, font=2)
  text(90, 70, round(as.numeric(cm$byClass[11]), 3), cex=1.2)
  
  # add in the accuracy information 
  text(30, 35, names(cm$overall[1]), cex=1.5, font=2)
  text(30, 20, round(as.numeric(cm$overall[1]), 3), cex=1.4)
  text(70, 35, "Phi", cex=1.5, font=2)
  text(70, 20, round((res[1]*res[4] - res[3]*res[2]) / sqrt(prod(c(res[1]+res[3], res[2]+res[4], res[1]+res[2], res[3]+res[4]))), 3), cex=1.4)
}
```

In terms of the two Logistic regression models, their performances appear to be highly similar as there are only minuscule differences across the measures such as Accuracy and Phi (Figures 6.1 and 6.2). However, neither model meets the company’s target for Specificity at the 0.5 threshold. To have the Specificity of 95% while keeping the Sensitivity of at least 90%, the threshold needs to be around 0.51 for the LASSO model and 0.52 for the Sink model according to their ROC curves (Figure 6.7). Despite this, Logit models are still less attractive compared to the other classifiers due to their inherent linear decision boundary in contrast with the more flexible decision boundaries of the other models as demonstrated in Figure 6.3.
```
LASSOlogit <- predict(lasso.fit,s = lasso.bestlam,newx = as.matrix(airlineScaled[testSet,-1]),type="response")
# Threshold
threshold <- 0.5
# Classification
(LASSOlogit>threshold) |>factor(levels=c(FALSE,TRUE), labels=c("No","Yes")) -> LASSOlogitPredictClass

lacm <- confusionMatrix(LASSOlogitPredictClass, airlineScaled[testSet,1] ,positive="Yes")
draw_confusion_matrix(lacm, "lasso logit")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/lassologit.cm.png" alt="lasso logit cm" width=600/>
</p>
<p align="center">Figure 6.1: LASSO Logit Model’s Confusion Matrix at 0.5 threshold</p>

```
SINKlogit <- glm(satisfaction ~ ., 
                   data=airlineScaled,
                   subset=trainSet,family = binomial)
SINKlogitPredict <- predict(SINKlogit,newdata=airlineScaled[testSet,],type="response")
(SINKlogitPredict>threshold) |>factor(levels=c(FALSE,TRUE), labels=c("No","Yes")) -> SinklogitModelPredictClass
sicm <- confusionMatrix(SinklogitModelPredictClass,airlineScaled$satisfaction[testSet],positive="Yes")
draw_confusion_matrix(sicm, "sink logit")
```

<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/sinklogit.cm.png" alt="sink logit cm" width=600/>
</p>
<p align="center">Figure 6.2: Sink Logit Model’s Confusion Matrix at 0.5 threshold</p>

```
airlineScaled_wMDS <- cbind(airlineScaled, allMDS)
airlineScaled_wMDS$D1 <- (airlineScaled_wMDS$D1-min(airlineScaled_wMDS$D1)) /(max(airlineScaled_wMDS$D1)-min(airlineScaled_wMDS$D1))
airlineScaled_wMDS$D2 <- (airlineScaled_wMDS$D2-min(airlineScaled_wMDS$D2)) /(max(airlineScaled_wMDS$D2)-min(airlineScaled_wMDS$D2))
airlineScaled_wMDS$satisfaction1 <- ifelse(airlineScaled_wMDS$satisfaction=="Yes", 1,0)

RFPredictz <- predict(RFTrain, newdata=airlineScaled_wMDS,type="prob")
BagPredictz <- predict(DTBagTrain, newdata=airlineScaled_wMDS,type="prob")
thresholdValues <- c(0.1, 0.3, 0.5, 0.9)
plot.thresholds <- function(pred,data,thresholdValues){
  par(mfrow=c(2,2))
  for(i in 1:4){
    z <- data$satisfaction=="Yes"

    plot(data$D1[z==0], data$D2[z==0],col="grey", xlab="D1", ylab="D2",main=paste0("Threshold of ",thresholdValues[i]))

    x <- (pred[,2]>thresholdValues[i])*1
    points(data$D1, data$D2,col=c(rgb(0.5,0.5,0.9,0.5), rgb(0.9,0.5,0.5,0.5))[x+1], pch=20)
    #Add actual "Yes" values
    # points(data$D1[z==1], data$D2[z==1],col=rgb(0,0,0,0.35))
  }
}
plot.thresholds(RFPredictz, airlineScaled_wMDS, thresholdValues)
plot.thresholds(BagPredictz, airlineScaled_wMDS, thresholdValues)
```

<p align="center">
  <table>
    <tr>
      <td> <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/Bagthresholds.png"  alt="1"></td>
      <td><img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/RFthresholds.png" alt="2" ></td>
     </tr> 
     <tr>
        <td><img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/RFthresholds.wActuals.png" alt="3"></td>
    </tr>
  </table>
<p align="center">Figure 6.3: Data (after MDS) split based on 17-NN (upper left); RF (upper right) & RF with black ‘satisfied’ points added (bottom left)</p>

On the other hand, the 17-NN model seems to be the least promising as it does not meet the airline’s targets at any threshold level based on the ROC plot (Figure 6.7). It also has the weakest expected predictive performance across different measures derived from the confusion matrix (Figure 6.4).
```
knnModelPredict <- predict(knnTrain, newdata=airlineScaled[testSet,],type="raw")
knnModelPredictProb <- predict(knnTrain, newdata=airlineScaled[testSet,],type="prob")
knncm <- confusionMatrix(knnModelPredict,as.factor(airlineScaled$satisfaction[testSet]),positive="Yes")
draw_confusion_matrix(knncm, "17-NN")
```

<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/17nn.cm.png" alt="knn cm" width=600/>
</p>
<p align="center">Figure 6.4: 17-NN’s Confusion Matrix at 0.5 threshold</p>

Notably, the best models come from the Tree-based method, with the clear winner being RF. As observed in Figures 2.5 and 2.6, Bagging and RF predicted the outcomes accurately for around 94.4% and 95.4% of the times respectively. Among the presented models, these two’s corresponding Phi values of 0.887 and 0.907 demonstrate the highest associations between the predicted and actual values. The proportions of satisfied customers that are correctly predicted out of all ‘positive’ predictions (Precision) are the largest for these models as well. Most importantly, Bagging and RF both meet the airline’s goal regarding Sensitivity and Specificity at the 0.5 threshold level, although the latter model is slightly better.
```
DTBagPredict <- predict(DTBagTrain, newdata=airlineScaled[testSet,],type="raw")
DTBagPredictProb <- predict(DTBagTrain, newdata=airlineScaled[testSet,],type="prob")
bgcm <- confusionMatrix(DTBagPredict,airlineScaled$satisfaction[testSet], positive="Yes")
draw_confusion_matrix(bgcm, "bagging")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/bagging.cm.png" alt="bagging cm" width=600/>
</p>
<p align="center">Figure 6.5: Bagging’s Confusion Matrix at 0.5 threshold</p>

```
#RF model's confusion matrix
RFProbabilities <- predict(RFTrain, newdata=airlineScaled[testSet,],type="prob")
# Adjust the predicted class based on the set threshold
RFPredict <- ifelse(RFProbabilities[, "Yes"] > threshold, "Yes", "No")
# Convert the predicted class labels to a factor with the same levels as the true class labels
RFPredict <- factor(RFPredict, levels = levels(airlineScaled$satisfaction))
RFPredictProb <- predict(RFTrain, newdata=airlineScaled[testSet,],type="prob")
rfcm <- confusionMatrix(RFPredict, airlineScaled$satisfaction[testSet], positive = "Yes")
draw_confusion_matrix(rfcm, "Random Forest")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/RF.cm.png" alt="RF cm" width=600/>
</p>
<p align="center">Figure 6.6: RF’s Confusion Matrix at 0.5 threshold (mtry=30)</p>

### TPR and TNR Trade-off
The candidate models are then compared in the context of the trade-off between True Positive and True Negative Rates, with greater emphasis on the most promising model RF. The ROC curves of each model, which visualise the trade-off, are displayed in Figure 6.7. It is observed that as the threshold increases, the proportions of correctly identified dissatisfied customers for all models also increase, while the opposite is true for the proportions of correctly identified satisfied customers. In terms of AUC, the Tree-based approaches outperform all other models, showing strong class discrimination ability.
```
rocCurves <- vector("list", 5)
# We only need the second column for the purposes of the analysis
rocCurves[[1]] <- roc(airlineScaled$satisfaction[testSet] ~ knnModelPredictProb[,2])
rocCurves[[2]] <- roc(airlineScaled$satisfaction[testSet] ~ SINKlogitPredict)
rocCurves[[3]] <- roc(airlineScaled$satisfaction[testSet] ~ LASSOlogit)
rocCurves[[4]] <- roc(airlineScaled$satisfaction[testSet] ~ DTBagPredictProb[,2])
rocCurves[[5]] <- roc(airlineScaled$satisfaction[testSet] ~ RFPredictProb[,2])
names(rocCurves) <- c("17-NN","Sink Logit", "LASSO Logit", "DTBag", "RF")
par(mfrow=c(3,2))
for(i in 1:5){
  # Plot each of the ROC curves
  plot(rocCurves[[i]], print.auc=TRUE, auc.polygon=TRUE,mar=c(4,4,0,0), grid=TRUE)
  # Add titles to plots
  text(1.1, 0.9, names(rocCurves)[i])
}
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/ROCcurves.ofall.png" alt="ROC curves" width=800/>
</p>
<p align="center">Figure 6.7: ROC curves of all candidate models</p>

Considering that the company’s specific targets for Sensitivity and Specificity are at least 90% and 95% respectively, the ideal threshold range that can achieve these for RF is around 0.43 and 0.62, which is approximately the area highlighted green in Figure 6.8. If the goal was to prioritise Specificity, then the upper thresholds would be preferred. Conversely, the lower thresholds would be better if the goal was only to maximise Sensitivity. However, overall performance should always be taken into consideration. This can be reflected in measures like Accuracy & Phi coefficients and these are maximised when the threshold is around 0.5 for RF (Figure 6.9).
```
rocObj <- roc(airlineScaled$satisfaction[testSet] ~ RFPredictProb[,2])
roc_df <- data.frame(spec = rocObj$specificities, sen = rocObj$sensitivities, threshold = rocObj$thresholds)
# Plot ROC curve with different thresholds
ggplot(roc_df, aes(x = spec, y = sen)) +
  geom_line() +
  geom_abline(intercept = 1, slope = 1, linetype = "dashed") +
  geom_point(aes(color = threshold), size = 2) +
  scale_color_gradientn(colors = c("hotpink", "green", "blue"), limits = c(0, 1), na.value = NA) +
  ggtitle("Random Forest's ROC Curve") +
  xlab("Specificity") +
  ylab("Sensitivity") + xlim(1,0)
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/RF.ROCcurve.png" alt="RF ROC" width=600/>
</p>
<p align="center">Figure 6.8: ROC curve of RF</p>

```
#Define threshold levels
thresholds <- c(0.1, 0.3, 0.5, 0.9)

#Empty data frame to store results
result_table <- data.frame(
  Threshold = thresholds,
  Sensitivity = numeric(length(thresholds)),
  Specificity = numeric(length(thresholds)),
  Accuracy = numeric(length(thresholds)),
  Phi = numeric(length(thresholds))
)

for (i in 1:length(thresholds)) {
  threshold1 <- thresholds[i]
  
  #Adjust the predicted class based on the custom threshold
  RFPredict1 <- ifelse(RFProbabilities[, "Yes"] > threshold1, "Yes", "No")
  
  #Convert the predicted class labels to a factor with the same levels as the true class labels
  RFPredict1 <- factor(RFPredict1, levels = levels(airlineScaled$satisfaction))
  
  #Calculate confusion matrix
  rfcm1 <- confusionMatrix(RFPredict1, airlineScaled$satisfaction[testSet], positive = "Yes")
  
  #Store performance metrics in the result table
  result_table[i, "Sensitivity"] <- round(rfcm1[["byClass"]][["Sensitivity"]], 3)
  result_table[i, "Specificity"] <- round(rfcm1[["byClass"]][["Specificity"]], 3)
  result_table[i, "Accuracy"] <- round(rfcm1[["overall"]][["Accuracy"]], 3)
  result_table[i, "Phi"] <- round((rfcm1$table[1]*rfcm1$table[4] - rfcm1$table[3]*rfcm1$table[2]) / 
                                    sqrt(prod(c(rfcm1$table[1]+rfcm1$table[3], 
                                                rfcm1$table[2]+rfcm1$table[4], 
                                                rfcm1$table[1]+rfcm1$table[2], 
                                                rfcm1$table[3]+rfcm1$table[4]))), 3)
}

print(result_table)
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/RFmetrics.diffthres.png" alt="RF performance" width=400/>
</p>
<p align="center">Figure 6.9: Performance measures of RF at different thresholds</p>

Given its better expected overall performance, RF is chosen to be the final recommended model.

### Variable Importance
The relative mean Gini index decrease for each variable in the dataset used to train RF is plotted in Figure 7.1. Based on its perfect Importance score, Business class is by far the most influential in predicting satisfaction. This aligns with the analysis in Part 1 as customers traveling in the airline’s Business class tend to have a more enjoyable flying experience. High ratings of services such as Inflight WIFI, Online boarding and Inflight entertainment, and Personal travel type along with Loyal customer type are other key predictors of satisfaction according to their relative importance values. From the plot, it is argued that Arrival delay, Inflight service, Onboard service, Baggage handling, Ease of online booking, Leg room service, Checkin service, Gate location, Cleanliness and Food & drink are the least important variables sets.

It is then decided to retrain the RF model after removing these less important variables from the dataset to see whether they truly have minimal impact on the predictive performance of the model. Another reason for having fewer variables is to reduce model complexity and computational requirement. This new model is trained on the data with 22 predictors. The final number of variables tried at each split that maximises ROC is 12. Figure 7.2 presents the confusion matrix of the new RF model at the 0.5 threshold level. Notably, this model still meets the company’s requirements regarding Specificity and Sensitivity. In addition, the model’s level of accuracy and agreement between predicted vs. actual values are relatively high, indicating a sufficiently good classifier.
```
varImp(RFTrain) |> plot()
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/RF.varimp.png" alt="Varimp" width=700/>
</p>
<p align="center">Figure 7.1: Variable importance from RF</p>

```
#Retrain RF model now with only high importance variables
lowimp.var <- c("Arrival.Delay.in.Minutes", grep("Inflight.service|On.board.service|Baggage.handling|Ease.of.Online.booking|Leg.room.service|Checkin.service|Gate.location|Cleanliness|Food.and.drink", names(airlineScaled), value = TRUE))
set.seed(41)
RFTrain.new <- train(satisfaction~., data=airlineScaled[trainSet,-which(names(airlineScaled) %in% lowimp.var)],method="rf",trControl=TrainControl,metric="ROC")
RFTrain.new

#RF model's confusion matrix
RFProbabilities.new <- predict(RFTrain.new, newdata=airlineScaled[testSet,-which(names(airlineScaled) %in% lowimp.var)],type="prob")
# Adjust the predicted class based on the custom threshold
RFPredict.new <- ifelse(RFProbabilities.new[, "Yes"] > threshold, "Yes", "No")
# Convert the predicted class labels to a factor with the same levels as the true class labels
RFPredict.new <- factor(RFPredict.new, levels = levels(airlineScaled$satisfaction))
rfcm.new <- confusionMatrix(RFPredict.new, airlineScaled$satisfaction[testSet], positive = "Yes")

draw_confusion_matrix(rfcm.new, "(mtry=12) Random forest")
```
<p align="center">
  <img src="https://github.com/dieu-nguyen24/UKAirline-Predictions/blob/main/Images/mtry12.rfcm.png" alt="RF mtry12" width=600/>
</p>
<p align="center">Figure 7.2: RF’s Confusion Matrix with mtry = 12</p>

### Conclusions from Modelling
- RF has consistently proven to be the most suitable predictive model among four other prospective approaches to help the airline predict customer satisfaction based on available data. Specifically, RF satisfies the required Specificity and Sensitivity of at least 95% and 90% respectively when the classification threshold is around 0.43 to 0.62.
- Regarding expected generalisation performance, the RF model surpasses LASSO Logit, Sink Logit, 17-NN, and Bagging in terms of Accuracy, Phi, and AUC among other measures.
- Only 21 out of 59 variables, which is actually 8 out of 16 sets of predictors, are needed to produce a sufficiently good classification model. This model trained on fewer variables has the clear advantage of reduced complexity for the user, while still meeting the TPR and TNR goals.

## References
James, G. et al. (2021) An introduction to statistical learning: With applications in R. Boston: Springer.
