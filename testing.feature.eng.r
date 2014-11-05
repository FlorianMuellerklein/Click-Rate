library(plyr)
library(dplyr)
library(data.table)
library(biglm)

###################################
#Olives edit! 
#This is all a comment! WOW! 

setwd("/Volumes/Cruzer/R/Click Rate")
data = fread('saturday.train.csv', verbose = T)
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
data$hour.ctr[data$actualhour == '00'] = hour.ctr[hour.ctr$actualhour == '00', 'ratio']
data$hour.ctr[data$actualhour == '01'] = hour.ctr[hour.ctr$actualhour == '01', 'ratio'] 
data$hour.ctr[data$actualhour == '02'] = hour.ctr[hour.ctr$actualhour == '02', 'ratio'] 
data$hour.ctr[data$actualhour == '03'] = hour.ctr[hour.ctr$actualhour == '03', 'ratio'] 
data$hour.ctr[data$actualhour == '04'] = hour.ctr[hour.ctr$actualhour == '04', 'ratio'] 
data$hour.ctr[data$actualhour == '05'] = hour.ctr[hour.ctr$actualhour == '05', 'ratio'] 
data$hour.ctr[data$actualhour == '06'] = hour.ctr[hour.ctr$actualhour == '06', 'ratio'] 
data$hour.ctr[data$actualhour == '07'] = hour.ctr[hour.ctr$actualhour == '07', 'ratio'] 
data$hour.ctr[data$actualhour == '08'] = hour.ctr[hour.ctr$actualhour == '08', 'ratio'] 
data$hour.ctr[data$actualhour == '09'] = hour.ctr[hour.ctr$actualhour == '09', 'ratio'] 
data$hour.ctr[data$actualhour == '10'] = hour.ctr[hour.ctr$actualhour == '10', 'ratio'] 
data$hour.ctr[data$actualhour == '11'] = hour.ctr[hour.ctr$actualhour == '11', 'ratio'] 
data$hour.ctr[data$actualhour == '12'] = hour.ctr[hour.ctr$actualhour == '12', 'ratio'] 
data$hour.ctr[data$actualhour == '13'] = hour.ctr[hour.ctr$actualhour == '13', 'ratio'] 
data$hour.ctr[data$actualhour == '14'] = hour.ctr[hour.ctr$actualhour == '14', 'ratio'] 
data$hour.ctr[data$actualhour == '15'] = hour.ctr[hour.ctr$actualhour == '15', 'ratio'] 
data$hour.ctr[data$actualhour == '16'] = hour.ctr[hour.ctr$actualhour == '16', 'ratio'] 
data$hour.ctr[data$actualhour == '17'] = hour.ctr[hour.ctr$actualhour == '17', 'ratio'] 
data$hour.ctr[data$actualhour == '18'] = hour.ctr[hour.ctr$actualhour == '18', 'ratio'] 
data$hour.ctr[data$actualhour == '19'] = hour.ctr[hour.ctr$actualhour == '19', 'ratio'] 
data$hour.ctr[data$actualhour == '20'] = hour.ctr[hour.ctr$actualhour == '20', 'ratio'] 
data$hour.ctr[data$actualhour == '21'] = hour.ctr[hour.ctr$actualhour == '21', 'ratio'] 
data$hour.ctr[data$actualhour == '22'] = hour.ctr[hour.ctr$actualhour == '22', 'ratio']
data$hour.ctr[data$actualhour == '23'] = hour.ctr[hour.ctr$actualhour == '23', 'ratio']

#calcute click rate per C21 and add those rates to a new column in data
C21.ctr = data %>% group_by(C21) %>% summarise(ratio = sum(click ==1) / length(click))
C21.ctr = data.frame(C21.ctr)
data$C21.ctr[data$C21 == 0] = C21.ctr[C21.ctr$C21 == 0, 'ratio']
data$C21.ctr[data$C21 == 1] = C21.ctr[C21.ctr$C21 == 1, 'ratio']
data$C21.ctr[data$C21 == 2] = C21.ctr[C21.ctr$C21 == 2, 'ratio']
data$C21.ctr[data$C21 == 3] = C21.ctr[C21.ctr$C21 == 3, 'ratio']

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

###################################
#Logistic Regression CV with logloss calculation

indices = sample(1:nrow(data), nrow(data) * .8)
train.cv = data[indices, ]
test.cv = data[-indices, ]

formula = click ~ C21 + actualhour + C22 + C24 + app_category + site_category + C19 + C18 + hour.ctr + C21.ctr + C22.ctr + C24.ctr
click.logit = glm(formula, data = train.cv, family = 'binomial')

prediction = predict(click.logit, newdata = test.cv, type = 'response')
actual = test.cv$click

###################################
# Est. prediction 
# epsilon = error 

llfun <- function(actual, prediction) {
    epsilon <- .000000000000001
    yhat <- pmin(pmax(prediction, epsilon), 1 - epsilon)
    logloss <- -mean(actual*log(yhat)
                     + (1-actual)*log(1 - yhat))
    return(logloss)
}

llfun(actual, prediction)