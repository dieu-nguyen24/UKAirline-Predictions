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


setwd("...") #Set working directory
source("Rfunctions.R")
airlinesData68 <- read_csv("airlinesData68.csv")

colnames(airlinesData68) <- make.names(colnames(airlinesData68)) #Remove spaces from column names

airlinesData68 <- airlinesData68 %>% 
  dplyr::select(satisfaction, everything()) #Move the target variable to the first column

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

#Turn 0s into NAs
airlinesData68[, rating_columns] <- lapply(airlinesData68[, rating_columns], function(x) replace(x, x==0, NA))

#Check dimensions and structure of dataset
dim(airlinesData68)
str(airlinesData68)
#Check for NAs
sum(is.na(airlinesData68))

#Make another copy of the processed data
airlinesData68EDA <- airlinesData68

#Turn values under 14 in Age column into NAs
airlinesData68EDA$Age <- replace(airlinesData68EDA$Age, airlinesData68EDA$Age < 14, NA)

#Remove all NA values
airlinesData68noNA <- na.omit(airlinesData68EDA)
#Check for NAs again
sum(is.na(airlinesData68noNA))

str(airlinesData68noNA)
dim(airlinesData68noNA)

#Snapshot of the dataset
vis_miss(airlinesData68) #raw

vis_dat(airlinesData68EDA) + scale_fill_manual(
  values = c(
    "factor" = "lightblue",
    "numeric" = "lightpink",
    "NA" = "black"
  ))


summary(airlinesData68noNA)

#WoE and IV
y <- airlinesData68noNA$satisfaction=="satisfied"
class(y)

y <- 1*y
class(y)

airlinesData68noNA["class"] <- y

IV <- create_infotables(data=airlinesData68noNA[,-c(1)], y="class", bins=6)
IV

#Density, scatter plots
ggpairs(airlinesData68noNA, aes(color = satisfaction), columns = c("Departure.Delay.in.Minutes",
                                                                   "Arrival.Delay.in.Minutes",
                                                                   "Flight.Distance"))

### Class Conditional Barplot
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
    # ggtitle(paste("Conditional Probability of ",x,"given",y))
  }
  
  if (main != "") {
    p <- p + ggtitle(label=main) + theme(plot.title = element_text(hjust = 0.5))
  }
  print(p)
}

#Conditional Probability Bar Plot of predictors given satisfaction
cc_barplot(Data = airlinesData68noNA, "Gender","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Gender given customer satisfaction")

cc_barplot(Data = airlinesData68noNA, "Ease.of.Online.booking","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Ease of Online booking given customer satisfaction")

cc_barplot(Data = airlinesData68noNA, "Seat.comfort","satisfaction",
           freq = "condprob",
           main = "Conditional probability of Seat comfort given customer satisfaction")

cc_barplot(Data = airlinesData68noNA, "On.board.service","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Onboard service given customer satisfaction")

cc_barplot(Data = airlinesData68noNA, "Cleanliness",
           "satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Cleanliness given customer satisfaction")

cc_barplot(Data = airlinesData68noNA, 
           "Baggage.handling","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Baggage handling given customer satisfaction")

cc_barplot(Data = airlinesData68noNA,
           "Inflight.service","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Inflight service given customer satisfaction")

cc_barplot(Data = airlinesData68noNA, 
           "Online.boarding","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Online boarding satisfaction given Overall airline satisfaction")

cc_barplot(Data = airlinesData68noNA, 
           "Inflight.entertainment","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Inflight entertainment given customer satisfaction")

cc_barplot(Data = airlinesData68noNA, 
           "Inflight.wifi.service","satisfaction", 
           freq = "condprob", 
           main = "Conditional probability of Inflight wifi service given customer satisfaction")

#Conditional Density Plot of Age given Satisfaction
densityplot(~Age, data=airlinesData68noNA, groups = satisfaction, 
            auto.key = TRUE, main = "Conditional density P(Age|Satisfaction)")

#Plot WoE values of all independent variables
lapply(colnames(airlinesData68noNA[,-c(1,24)]), function(variable) plot_infotables(IV, variable))

#Correlation plot
corrplot(association(airlinesData68noNA[,-24])$value)

#Log transform Arrival Delay variable
airlinesData68noNA$Arrival.Delay.tf <- airlinesData68noNA$Arrival.Delay.in.Minutes + 1
airlinesData68noNA$Arrival.Delay.tf <- log10(airlinesData68noNA$Arrival.Delay.tf)

#Compare the skewness of original and transformed Arrival Delay variable
skewness(airlinesData68noNA$Arrival.Delay.tf)
skewness(airlinesData68noNA$Arrival.Delay.in.Minutes)

#Remove chosen variables
cols_torm <- c("satisfaction","Type.of.Travel","Inflight.service",
               "Departure.Delay.in.Minutes", "Gender",
               "Gate.location","Departure.Arrival.time.convenient", "Arrival.Delay.in.Minutes", "class")

airline_transformed <- airlinesData68noNA[,-which(names(airlinesData68noNA) %in% cols_torm)]

#Take a sample of 1000 observations
set.seed(0)
airlinesData68_sample <- sample_n(airline_transformed, 1000)

airlinesData68DissimMatrix <- daisy(airlinesData68_sample, metric = "gower")

#Stress plot
#number of original dimensions
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

#Generate Dissimilarity Matrix using all data
distgower <- daisy(airline_transformed, metric = "gower")

#Perform MDS with 2 dimensions
allMDS <- cmdscale(distgower, k=2)

#Change column names to D1 (dimension 1) and D2 (dimension 2)
colnames(allMDS) <- c("D1", "D2")

#Visualise the 2 dimensions
plot(allMDS, main = "MDS data", xlim = c(-0.4, 0.5), ylim=c(-0.5, 0.4))

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

#Created different dataframes based on the clusters
C1 <-airlinesData68New[airlinesData68New$clusters==1,]
C2 <-airlinesData68New[airlinesData68New$clusters==2,]
C3 <-airlinesData68New[airlinesData68New$clusters==3,]

par(mfrow=c(5,4))
#C1
barplot(table(C1$Customer.Type), ylab = "Counts",  main="Customer Type", col = "lightblue")
hist(C1$Age, ylab = "Frequency",xlab="Age",main="Age", col = "lightblue")
barplot(table(C1$Class), ylab = "Counts",main="Class", col = "lightblue")
hist(C1$Flight.Distance, ylab = "Frequency",xlab="Miles", main="Flight Distance", col = "lightblue")
barplot(table(C1$Inflight.wifi.service), ylab = "Counts",main="Inflight WIFI service", col = "lightblue")
barplot(table(C1$Ease.of.Online.booking), ylab = "Counts",main="Ease of Online booking", col = "lightblue")
barplot(table(C1$Food.and.drink), ylab = "Counts",main="Food & drink", col = "lightblue")
barplot(table(C1$Online.boarding), ylab = "Counts",main="Online boarding", col = "lightblue")
barplot(table(C1$Seat.comfort), ylab = "Counts",main="Seat comfort", col = "lightblue")
barplot(table(C1$Inflight.entertainment), ylab = "Counts",main="Inflight entertainment", col = "lightblue")
barplot(table(C1$On.board.service), ylab = "Counts",main="Onboard service", col = "lightblue")
barplot(table(C1$Leg.room.service), ylab = "Counts",main="Leg room service", col = "lightblue")
barplot(table(C1$Baggage.handling), ylab = "Counts",main="Baggage handling", col = "lightblue")
barplot(table(C1$Checkin.service), ylab = "Counts",main="Checkin service", col = "lightblue")
barplot(table(C1$Cleanliness), ylab = "Counts",main="Cleanliness", col = "lightblue")
hist(C1$Arrival.Delay.in.Minutes, ylab = "Frequency",xlab="Minutes", main="Arrival Delay", col = "lightblue",bins=20)
barplot(table(C1$Gate.location), ylab = "Counts",main="Gate location", col = "lightblue")
barplot(table(C1$Departure.Arrival.time.convenient), ylab = "Counts",main="Time convenience", col = "lightblue")
barplot(table(C1$Gender), ylab = "Counts",main="Gender", col = "lightblue")
barplot(table(C1$Type.of.Travel), ylab = "Counts",main="Type of Travel", col = "lightblue")

#C2
barplot(table(C2$Customer.Type), ylab = "Counts",  main="Customer Type", col = "lightblue")
hist(C2$Age, ylab = "Frequency",xlab="Age",main="Age", col = "lightblue")
barplot(table(C2$Class), ylab = "Counts",main="Class", col = "lightblue")
hist(C2$Flight.Distance, ylab = "Frequency",xlab="Miles", main="Flight Distance", col = "lightblue")
barplot(table(airlinesData68New[airlinesData68New$clusters==2,7]), ylab = "Counts",main="Inflight WIFI service", col = "lightblue")
barplot(table(C2$Ease.of.Online.booking), ylab = "Counts",main="Ease of Online booking", col = "lightblue")
barplot(table(C2$Food.and.drink), ylab = "Counts",main="Food & drink", col = "lightblue")
barplot(table(C2$Online.boarding), ylab = "Counts",main="Online boarding", col = "lightblue")
barplot(table(C2$Seat.comfort), ylab = "Counts",main="Seat comfort", col = "lightblue")
barplot(table(C2$Inflight.entertainment), ylab = "Counts",main="Inflight entertainment", col = "lightblue")
barplot(table(C2$On.board.service), ylab = "Counts",main="Onboard service", col = "lightblue")
barplot(table(C2$Leg.room.service), ylab = "Counts",main="Leg room service", col = "lightblue")
barplot(table(C2$Baggage.handling), ylab = "Counts",main="Baggage handling", col = "lightblue")
barplot(table(C2$Checkin.service), ylab = "Counts",main="Checkin service", col = "lightblue")
barplot(table(C2$Cleanliness), ylab = "Counts",main="Cleanliness", col = "lightblue")
hist(C2$Arrival.Delay.in.Minutes, ylab = "Frequency",xlab="Minutes", main="Arrival Delay", col = "lightblue",bins=20)
barplot(table(C2$Gate.location), ylab = "Counts",main="Gate location", col = "lightblue")
barplot(table(C2$Departure.Arrival.time.convenient), ylab = "Counts",main="Time convenience", col = "lightblue")
barplot(table(C2$Gender), ylab = "Counts",main="Gender", col = "lightblue")
barplot(table(C2$Type.of.Travel), ylab = "Counts",main="Type of Travel", col = "lightblue")


#C3
barplot(table(C3$Customer.Type), ylab = "Counts",  main="Customer Type", col = "lightblue")
hist(C3$Age, ylab = "Frequency",xlab="Age",main="Age", col = "lightblue")
barplot(table(C3$Class), ylab = "Counts",main="Class", col = "lightblue")
hist(C3$Flight.Distance, ylab = "Frequency",xlab="Miles", main="Flight Distance", col = "lightblue")
barplot(table(airlinesData68New[airlinesData68New$clusters==3,7]), ylab = "Counts",main="Inflight WIFI service", col = "lightblue")
barplot(table(C3$Ease.of.Online.booking), ylab = "Counts",main="Ease of Online booking", col = "lightblue")
barplot(table(C3$Food.and.drink), ylab = "Counts",main="Food & drink", col = "lightblue")
barplot(table(C3$Online.boarding), ylab = "Counts",main="Online boarding", col = "lightblue")
barplot(table(C3$Seat.comfort), ylab = "Counts",main="Seat comfort", col = "lightblue")
barplot(table(C3$Inflight.entertainment), ylab = "Counts",main="Inflight entertainment", col = "lightblue")
barplot(table(C3$On.board.service), ylab = "Counts",main="Onboard service", col = "lightblue")
barplot(table(C3$Leg.room.service), ylab = "Counts",main="Leg room service", col = "lightblue")
barplot(table(C3$Baggage.handling), ylab = "Counts",main="Baggage handling", col = "lightblue")
barplot(table(C3$Checkin.service), ylab = "Counts",main="Checkin service", col = "lightblue")
barplot(table(C3$Cleanliness), ylab = "Counts",main="Cleanliness", col = "lightblue")
hist(C3$Arrival.Delay.in.Minutes, ylab = "Frequency",xlab="Minutes", main="Arrival Delay", col = "lightblue",bins=20)
barplot(table(C3$Gate.location), ylab = "Counts",main="Gate location", col = "lightblue")
barplot(table(C3$Departure.Arrival.time.convenient), ylab = "Counts",main="Time convenience", col = "lightblue")
barplot(table(C3$Gender), ylab = "Counts",main="Gender", col = "lightblue")
barplot(table(C3$Type.of.Travel), ylab = "Counts",main="Type of Travel", col = "lightblue")

par(mfrow=c(1,1)) #Reset plot frame

cc_barplot(Data = airlinesData68New,"clusters","satisfaction", freq = "condprob",main="Conditional probability of Cluster given overall satisfaction")

#Spread plot
spread(airlinesData68New[,c(1,2,5,8,10,12,14:21,23)])

qplot(D1, D2, colour = airline_transformed$Inflight.entertainment, 
      data = airlinesData68New[,c(1,2)])+ scale_colour_discrete("Inflight Entertainment")
qplot(D1, D2, colour = airline_transformed$Cleanliness, 
      data = airlinesData68New[,c(1,2)])+ scale_colour_discrete("Cleanliness")
qplot(D1, D2, colour = airline_transformed$Food.and.drink, 
      data = airlinesData68New[,c(1,2)])+ scale_colour_discrete("Food & Drink")
qplot(D1, D2, colour = airline_transformed$Seat.comfort, 
      data = airlinesData68New[,c(1,2)])+ scale_colour_discrete("Seat comfort")


#####
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

# lasso.pred <- predict(lasso.fit.d2, s = lasso.bestlam,
#                       newx = x[test,])
# # MSE with minimum lambda
# mean((lasso.pred - y.test)^2)
# 
# lasso.pred.1se <- predict(lasso.fit.d2, s = lasso.cv.out$lambda.1se,
#                           newx = x[test,])
# print(lasso.cv.out$lambda.1se)
# 
# # MSE with the 1-SD rule lambda
# print(mean((lasso.pred.1se - y.test)^2))

lasso.coef.min.d2 <- predict(lasso.fit.d2, type = "coefficients",
                          s = lasso.bestlam)
print(lasso.coef.min.d2)

#########
#CLASSIFICATION PREDICTIONS
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

# Set a random seed for reproducibility
set.seed(10)
# All observations used in this workshop
obsAll <- nrow(airlineScaled)
# Split the data to 75%/25%
trainSet <- sample(1:obsAll, round(0.75*obsAll))
testSet <- (1:obsAll)[!(1:obsAll %in% trainSet)]

#####
#LOGISTIC REGRESSION
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
######
LASSOlogit <- predict(lasso.fit,s = lasso.bestlam,newx = as.matrix(airlineScaled[testSet,-1]),type="response")
# Threshold
threshold <- 0.5
# Classification
(LASSOlogit>threshold) |>factor(levels=c(FALSE,TRUE), labels=c("No","Yes")) -> LASSOlogitPredictClass

lacm <- confusionMatrix(LASSOlogitPredictClass, airlineScaled[testSet,1] ,positive="Yes")
lacm

#SINK Logit
SINKlogit <- glm(satisfaction ~ ., 
                   data=airlineScaled,
                   subset=trainSet,family = binomial)
summary(SINKlogit)

SINKlogitPredict <- predict(SINKlogit,newdata=airlineScaled[testSet,],type="response")

# Classification
(SINKlogitPredict>threshold) |>factor(levels=c(FALSE,TRUE), labels=c("No","Yes")) ->SinklogitModelPredictClass

sicm <- confusionMatrix(SinklogitModelPredictClass,airlineScaled$satisfaction[testSet],positive="Yes")
sicm

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

#KNN model's confusion matrix
knnModelPredict <- predict(knnTrain, newdata=airlineScaled[testSet,],type="raw")
knncm <- confusionMatrix(knnModelPredict,as.factor(airlineScaled$satisfaction[testSet]),positive="Yes")

knnModelPredictProb <- predict(knnTrain, newdata=airlineScaled[testSet,],type="prob")

#CART
#Decision Tree
set.seed(41)
DTTrain <- train(satisfaction~., data=airlineScaled,method="rpart", 
                 trControl=TrainControl,metric="ROC", tuneLength=10)

# Set seed to train the model in the same way as before
set.seed(41)
#Train Bagging model
DTBagTrain <- train(satisfaction~., data=airlineScaled[trainSet,],method="treebag",trControl=TrainControl,metric="ROC")
DTBagTrain
DTBagPredictProb <- predict(DTBagTrain, newdata=airlineScaled[testSet,],type="prob")


#Bagging model's confusion matrix
DTBagPredict <- predict(DTBagTrain, newdata=airlineScaled[testSet,],type="raw")
bgcm <- confusionMatrix(DTBagPredict,airlineScaled$satisfaction[testSet], positive="Yes")

#train Random Forest model
set.seed(41)
RFTrain <- train(satisfaction~., data=airlineScaled[trainSet,],method="rf",trControl=TrainControl,metric="ROC")
RFTrain

#RF model's confusion matrix
RFProbabilities <- predict(RFTrain, newdata=airlineScaled[testSet,],type="prob")
# Adjust the predicted class based on the custom threshold
RFPredict <- ifelse(RFProbabilities[, "Yes"] > threshold, "Yes", "No")
# Convert the predicted class labels to a factor with the same levels as the true class labels
RFPredict <- factor(RFPredict, levels = levels(airlineScaled$satisfaction))
rfcm <- confusionMatrix(RFPredict, airlineScaled$satisfaction[testSet], positive = "Yes")
RFPredictProb <- predict(RFTrain, newdata=airlineScaled[testSet,],type="prob")

#Confusion matrices
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

draw_confusion_matrix(lacm, "lasso logit")
draw_confusion_matrix(sicm, "sink logit")
draw_confusion_matrix(rfcm, "Random Forest")
draw_confusion_matrix(bgcm, "bagging")
draw_confusion_matrix(knncm, "17-NN")

airlineScaled_wMDS <- cbind(airlineScaled, allMDS)
airlineScaled_wMDS$D1 <- (airlineScaled_wMDS$D1-min(airlineScaled_wMDS$D1)) /(max(airlineScaled_wMDS$D1)-min(airlineScaled_wMDS$D1))
airlineScaled_wMDS$D2 <- (airlineScaled_wMDS$D2-min(airlineScaled_wMDS$D2)) /(max(airlineScaled_wMDS$D2)-min(airlineScaled_wMDS$D2))
airlineScaled_wMDS$satisfaction1 <- ifelse(airlineScaled_wMDS$satisfaction=="Yes", 1,0)

#Decision boundary
# Get estimates of parameters
hb <- coef(SINKlogit)
# Order the response variable
# This is needed to plot the values for 1 above the zero ones.
satOrder <- order(airlineScaled_wMDS$satisfaction1)
# Create variables for the scatterplot, order them
d1 <- airlineScaled_wMDS$D1[satOrder]
d2 <- airlineScaled_wMDS$D2[satOrder]
o <- airlineScaled_wMDS$satisfaction1[satOrder]
# Scatterplot of income against balance using "defaulted" to colour data
plot(d1, d2, col=c("grey","black")[o+1], pch=c(1,20)[o+1],xlab="D1", ylab="D2")


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
par(mfrow=c(1,1))

rocObj <- roc(airlineScaled$satisfaction[testSet] ~ RFPredictProb[,2])
plot(rocObj, main = "Random Forest's ROC Curve", xlab = "Specificity", ylab = "Sensitivity",print.auc=TRUE, auc.polygon=TRUE, grid=TRUE)
auc(rocObj)

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


# Define threshold levels
thresholds <- c(0.1, 0.3, 0.5, 0.9)

# Empty data frame to store results
result_table <- data.frame(
  Threshold = thresholds,
  Sensitivity = numeric(length(thresholds)),
  Specificity = numeric(length(thresholds)),
  Accuracy = numeric(length(thresholds)),
  Phi = numeric(length(thresholds))
)

for (i in 1:length(thresholds)) {
  threshold1 <- thresholds[i]
  
  # Adjust the predicted class based on the custom threshold
  RFPredict1 <- ifelse(RFProbabilities[, "Yes"] > threshold1, "Yes", "No")
  
  # Convert the predicted class labels to a factor with the same levels as the true class labels
  RFPredict1 <- factor(RFPredict1, levels = levels(airlineScaled$satisfaction))
  
  # Calculate confusion matrix
  rfcm1 <- confusionMatrix(RFPredict1, airlineScaled$satisfaction[testSet], positive = "Yes")
  
  # Store performance metrics in the result table
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

varImp(RFTrain) |> plot()

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
