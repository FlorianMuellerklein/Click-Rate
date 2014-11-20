library(plyr)
library(dplyr)
library(Matrix)
library(glmnet)
library(data.table)

#setwd("~/Documents/Kaggle/Click-Rate")
setwd("/Volumes/PSSD/Click Rate")
#data = read.csv('saturday.train.csv')
train = fread('train')
train = select(train, -site_id, - site_domain, -app_id, -device_id, -device_ip, -device_model, -C14)

####################################
#Prepare data

train$actualhour = as.character(substring(train$hour, 7,8))
train$day = weekdays(as.Date(strptime(as.character(train$hour), '%y%m%d %H')))

train$C1 = as.factor(train$C1)
train$banner_pos = as.factor(train$banner_pos)
train$site_category = as.factor(train$site_category)
train$app_domain = as.factor(train$app_domain)
train$app_category = as.factor(train$app_category)
train$device_type = as.factor(train$device_type)
train$device_conn_type = as.factor(train$device_conn_type)
train$C15 = as.factor(train$C15)
train$C16 = as.factor(train$C16)
train$C17 = as.factor(train$C17)
train$C18 = as.factor(train$C18)
train$C19 = as.factor(train$C19)
train$C20 = as.factor(train$C20)
train$C21 = as.factor(train$C21)
train$actualhour = as.factor(train$actualhour)
train$day = as.factor(train$day)

#################################
#Prepare data for testing
indices = sample(1:nrow(train), nrow(train) * .8)

click = select(train, click)
train = select(train, -click)

test = train[-indices, ]
test.click = click[-indices, ]
train = train[indices, ]
train.click = click[indices, ]

train = sparse.model.matrix(~ . , train, contrasts.arg = c("banner_pos", "site_category", "app_domain", "app_category", "device_type", "device_conn_type", "C15", "C16", "C17", "C18", "C19", "C20", "C21", "actualhour", "day"))
test = sparse.model.matrix(~ . , test, contrasts.arg = c("banner_pos", "site_category", "app_domain", "app_category", "device_type", "device_conn_type", "C15", "C16", "C17", "C18", "C19", "C20", "C21", "actualhour", "day"))

###################################
#regularized logistic regression with logloss calculation

glmnet.logit = glmnet(x = train, y = as.matrix(train.click), family = 'binomial', alpha = 1)
plot(glmnet.logit, xvar = 'lambda', label = T)
cv = cv.glmnet(train, as.matrix(train.click), alpha = 1)

prediction.m = predict(glmnet.logit, newx = test, type = 'response', s = cv$lambda.min)

llfun <- function(actual, prediction) {
    epsilon <- .000000000000001
    yhat <- pmin(pmax(prediction, epsilon), 1-epsilon)
    logloss <- -mean(actual*log(yhat)
                     + (1-actual)*log(1 - yhat))
    return(logloss)
}

print('Sparse matrix logistic regression')
llfun(as.matrix(test.click), as.matrix(prediction.m))

zigmoid = function(x) {
    return(1 / (1 + exp(-x)))
}