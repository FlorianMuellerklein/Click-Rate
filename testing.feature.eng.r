library(plyr)
library(dplyr)
library(data.table)
library(speedglm)

setwd("/Volumes/Cruzer/R/Click Rate")
data = read.csv('saturday.train.csv')
data = select(data, hour, C21, C22, C24, click, C19, C18, app_category, site_category)

###################################
#prepare data
data$C21 = factor(data$C21, ordered = F)
data$C22 = factor(data$C22, ordered = F)
data$C24 = factor(data$C24, ordered = F)
data$C19 = factor(data$C19, ordered = F)
data$C18 = factor(data$C18, ordered = F)
data$app_category = factor(data$app_category, ordered = F)
data$site_category = factor(data$site_category, ordered = F)

####################################
#Feature Engineering

#create variable of just the hours in a day
data$actualhour = as.character(substring(data$hour, 7,8))

#calcute click rate per hour and add those rates to a new column in data
hour.ctr = data %>% group_by(actualhour) %>% summarise(ratio = sum(click == 1) / length(click))
hour.ctr = data.frame(hour.ctr)
for (i in unique(data$actualhour)) {
    data$hour.ctr[data$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}
#data$hour.ctr[data$actualhour == '00'] = hour.ctr[hour.ctr$actualhour == '00', 'ratio']

#calcute click rate per C21 and add those rates to a new column in data
C21.ctr = data %>% group_by(C21) %>% summarise(ratio = sum(click ==1) / length(click))
C21.ctr = data.frame(C21.ctr)
for (i in unique(data$C21)) {
    data$C21.ctr[data$C21 == i] = C21.ctr[C21.ctr$C21 == i, 'ratio']
}
#data$C21.ctr[data$C21 == 0] = C21.ctr[C21.ctr$C21 == 0, 'ratio']

#calcute click rate per C22 and add those rates to a new column in data
C22.ctr = data %>% group_by(C22) %>% summarise(ratio = sum(click ==1) / length(click))
C22.ctr = data.frame(C22.ctr)
for (i in unique(data$C22)) {
    data$C22.ctr[data$C22 == i] = C22.ctr[C22.ctr$C22 == i, 'ratio']
}

#calcute click rate per C24 and add those rates to a new column in data
C24.ctr = data %>% group_by(C24) %>% summarise(ratio = sum(click ==1) / length(click))
C24.ctr = data.frame(C24.ctr)
for (i in unique(data$C24)) {
    data$C24.ctr[data$C24 == i] = C24.ctr[C24.ctr$C24 == i, 'ratio']
}

data$actualhour = as.numeric(data$actualhour)
rm(C21.ctr, C22.ctr, C24.ctr, hour.ctr)
###################################
#Logistic Regression CV with logloss calculation

indices = sample(1:nrow(data), nrow(data) * .8)
train.cv = data[indices, ]
test.cv = data[-indices, ]

formula = click ~ C21 + actualhour + C22 + C24 + C19 + C18 + hour.ctr + C21.ctr + C22.ctr + C24.ctr
click.logit = glm(formula, data = train.cv, family = 'binomial')

prediction = predict(click.logit, newdata = test.cv, type = 'response')
actual = test.cv$click


llfun <- function(actual, prediction) {
    epsilon <- .000000000000001
    yhat <- pmin(pmax(prediction, epsilon), 1-epsilon)
    logloss <- -mean(actual*log(yhat)
                     + (1-actual)*log(1 - yhat))
    return(logloss)
}

llfun(actual, prediction)