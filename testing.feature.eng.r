library(plyr)
library(dplyr)
library(Matrix)
library(glmnet)

setwd("/Volumes/CRUZER/R/Click Rate")
data = read.csv('saturday.train.csv')
data = select(data, click, hour, C21, C22, C24, C19, C18, app_category, site_category)

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
####################################

#create variable of just the hours in a day
data$actualhour = as.character(substring(data$hour, 7,8))

#Calculate click rates hour, C21, C22, C24, C19, C18, app_category, site_category
#use the smoothing function alpha * beta / beta with a unique beta for each column 

alpha = 0.14
beta = 250

#calcute click rate per hour and add those rates to a new column in data

hour.ctr = data %>% group_by(actualhour) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
hour.ctr = data.frame(hour.ctr)
for (i in unique(data$actualhour)) {
    data$hour.ctr[data$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

#calcute click rate per C21 and add those rates to a new column in data
C21.ctr = data %>% group_by(C21) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C21.ctr = data.frame(C21.ctr)
for (i in unique(data$C21)) {
    data$C21.ctr[data$C21 == i] = C21.ctr[C21.ctr$C21 == i, 'ratio']
}

#calcute click rate per C22 and add those rates to a new column in data
C22.ctr = data %>% group_by(C22) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C22.ctr = data.frame(C22.ctr)
for (i in unique(data$C22)) {
    data$C22.ctr[data$C22 == i] = C22.ctr[C22.ctr$C22 == i, 'ratio']
}

#calcute click rate per C24 and add those rates to a new column in data
C24.ctr = data %>% group_by(C24) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C24.ctr = data.frame(C24.ctr)
for (i in unique(data$C24)) {
    data$C24.ctr[data$C24 == i] = C24.ctr[C24.ctr$C24 == i, 'ratio']
}

#calcute click rate per C19 and add those rates to a new column in data
C19.ctr = data %>% group_by(C19) %>% summarise(ratio = sum(click ==1) / length(click))
C19.ctr = data.frame(C19.ctr)
for (i in unique(data$C19)) {
    data$C19.ctr[data$C19 == i] = C19.ctr[C19.ctr$C19 == i, 'ratio']
}

#calcute click rate per C18 and add those rates to a new column in data
C18.ctr = data %>% group_by(C18) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C18.ctr = data.frame(C18.ctr)
for (i in unique(data$C18)) {
    data$C18.ctr[data$C18 == i] = C18.ctr[C18.ctr$C18 == i, 'ratio']
}

#calcute click rate per app_category and add those rates to a new column in data
app.ctr = data %>% group_by(app_category) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
app.ctr = data.frame(app.ctr)
for (i in unique(data$app_category)) {
    data$app.ctr[data$app_category == i] = app.ctr[app.ctr$app_category == i, 'ratio']
}

#calcute click rate per site_category and add those rates to a new column in data
site.ctr = data %>% group_by(site_category) %>% summarise(ratio = sum(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta)))
site.ctr = data.frame(site.ctr)
for (i in unique(data$site_category)) {
    data$site.ctr[data$site_category == i] = site.ctr[site.ctr$site_category == i, 'ratio']
}

rm(C21.ctr, C22.ctr, C24.ctr, C19.ctr, C18.ctr, hour.ctr, site.ctr, app.ctr)

#hours to numeric
data$actualhour = as.factor(data$actualhour)

######
#Create sparse matrix for crazy encrypted variables
app.matrix = model.matrix(~ 0 + app_category, data)
site.matrix = model.matrix(~ 0 + site_category, data)
C21.matrix = model.matrix(~ 0 + C21, data)
C22.matrix = model.matrix(~ 0 + C22, data)
C24.matrix = model.matrix(~ 0 + C24, data)
C19.matrix = model.matrix(~ 0 + C19, data)
C18.matrix = model.matrix(~ 0 + C18, data)

data.matrix = cbind(app.matrix, site.matrix, C18.matrix, C19.matrix, C21.matrix, C22.matrix, C24.matrix)
rm(app.matrix, C18.matrix, C19.matrix, C21.matrix, C22.matrix, C24.matrix, site.matrix)
data = select(data, -hour, click, actualhour, hour.ctr, C21.ctr, C22.ctr, C24.ctr, C18.ctr, C19.ctr, app.ctr, site.ctr, C21, C22, C24, C18, C19)
data.matrix = cbind(data[,2:10], data.matrix)
###################################
#Logistic regression with logloss calculation

indices = sample(1:nrow(data.matrix), nrow(data.matrix) * .8)
train.nm = data[indices, ]
test.click = data[-indices, 1]
test.nm = data[-indices, -1]

trainy = data[indices, 1]

train.m = data.matrix[indices, ]
train.m = data.frame(train.m)
train.m = sparse.model.matrix(~ . , train.m)
test.m = data.matrix[-indices, ]
test.m = data.frame(test.m)
test.m = sparse.model.matrix(~ . , test.m)

rm(data, data.matrix)

#formula = click ~ C21 + actualhour + C22 + C24 + C19 + C18 + hour.ctr + C21.ctr + C22.ctr + C24.ctr

glmnet.logit = glmnet(x = train.m, y = as.matrix(trainy), family = 'binomial', alpha = 1)
cv = cv.glmnet(train.m, as.vector(trainy), alpha = 1)

click.logit = glm(click ~ ., data = train.nm, family = 'binomial')

prediction.nm = predict(click.logit, newdata = test.nm, type = 'response')
prediction.m = predict(glmnet.logit, newx = test.m, type = 'response', s = cv$lambda.min)
actual = as.numeric(test.click)


llfun <- function(actual, prediction) {
    epsilon <- .000000000000001
    yhat <- pmin(pmax(prediction, epsilon), 1-epsilon)
    logloss <- -mean(actual*log(yhat)
                     + (1-actual)*log(1 - yhat))
    return(logloss)
}

print('Sparse matrix logistic regression')
llfun(actual, prediction.m)

print('Standard logistic regression')
llfun(actual, prediction.nm)

print('Average of both')
mean.p = ave(prediction.m, prediction.nm)
llfun(actual, mean.p)
