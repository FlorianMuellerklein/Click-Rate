library(plyr)
library(dplyr)
library(Matrix)
library(glmnet)
library(data.table)

setwd("~/Documents/Kaggle/Click-Rate")
#setwd("/Volumes/PSSD/Click Rate")
train = fread('train')
#train = select(train, id, click, hour, C1, C15, C16, C18)
indices = sample(1:nrow(train), nrow(train) * .2)
train = train[indices, ]
rm(indices)

test = fread('test')
#test = select(test, id, hour, C1, C15, C16, C18)

####################################
#put '1' in for variables that don't exist in both sets

test$banner_pos = ifelse(test$banner_pos %in% unique(train$banner_pos), test$banner_pos, 1)
test$site_category = ifelse(test$site_category %in% unique(train$site_category), test$site_category, 1)
test$app_domain = ifelse(test$app_domain %in% unique(train$app_domain), test$app_domain, 1)
test$app_category = ifelse(test$app_category %in% unique(train$app_category), test$app_category, 1)
test$device_type = ifelse(test$device_type %in% unique(train$device_type), test$device_type, 1)
test$C17 = ifelse(test$C17 %in% unique(train$C17), test$C17, 1)
test$C19 = ifelse(test$C19 %in% unique(train$C19), test$C19, 1)
test$C20 = ifelse(test$C20 %in% unique(train$C20), test$C20, 1)
test$C21 = ifelse(test$C21 %in% unique(train$C21), test$C21, 1)

train$banner_pos = ifelse(train$banner_pos %in% unique(test$banner_pos), train$banner_pos, 1)
train$site_category = ifelse(train$site_category %in% unique(test$site_category), train$site_category, 1)
train$app_domain = ifelse(train$app_domain %in% unique(test$app_domain), train$app_domain, 1)
train$app_category = ifelse(train$app_category %in% unique(test$app_category), train$app_category, 1)
train$device_type = ifelse(train$device_type %in% unique(test$device_type), train$device_type, 1)
train$C17 = ifelse(train$C17 %in% unique(test$C17), train$C17, 1)
train$C19 = ifelse(train$C19 %in% unique(test$C19), train$C19, 1)
train$C20 = ifelse(train$C20 %in% unique(test$C20), train$C20, 1)
train$C21 = ifelse(train$C21 %in% unique(test$C21), train$C21, 1)

####################################
#Prepare data

#factorize and create hour and day variables for train
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

train = select(train, -hour, -id)

#factorize and create hour and day variables for test
test$actualhour = as.character(substring(test$hour, 7,8))
test$day = weekdays(as.Date(strptime(as.character(test$hour), '%y%m%d %H')))

test$C1 = as.factor(test$C1)
test$banner_pos = as.factor(test$banner_pos)
test$site_category = as.factor(test$site_category)
test$app_domain = as.factor(test$app_domain)
test$app_category = as.factor(test$app_category)
test$device_type = as.factor(test$device_type)
test$device_conn_type = as.factor(test$device_conn_type)
test$C15 = as.factor(test$C15)
test$C16 = as.factor(test$C16)
test$C17 = as.factor(test$C17)
test$C18 = as.factor(test$C18)
test$C19 = as.factor(test$C19)
test$C20 = as.factor(test$C20)
test$C21 = as.factor(test$C21)
test$actualhour = as.factor(test$actualhour)
test$day[1] = 'Monday'
test$day[2] = 'Tuesday'
test$day[3] = 'Wednesday'
test$day[4] = 'Thursday'
test$day[5] = 'Saturday'
test$day[6] = 'Sunday'
test$day = as.factor(test$day)

#add hour and day ctr to training set
hour.ctr = train %>% group_by(actualhour) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
hour.ctr = data.frame(hour.ctr)
for (i in unique(train$actualhour)) {
    train$hour.ctr[train$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

#calcute click rate per day and add those rates to a new column in data
day.ctr = train %>% group_by(day) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
day.ctr = data.frame(day.ctr)
for (i in unique(train$day)) {
    train$day.ctr[train$day == i] = day.ctr[day.ctr$day == i, 'ratio']
}

#add hour and day ctr to testing set
hour.ctr = data.frame(hour.ctr)
for (i in unique(test$actualhour)) {
    test$hour.ctr[test$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

#calcute click rate per day and add those rates to a new column in data
day.ctr = data.frame(day.ctr)
for (i in unique(test$day)) {
    test$day.ctr[test$day == i] = day.ctr[day.ctr$day == i, 'ratio']
}


####################################################################
#Prepare data for training

click = select(train, click)
train = select(train, -click)

train = sparse.model.matrix(~ . , train, contrasts.arg = c('C1', 'C15', 'C16', 'C18', 'actualhour', 'day'))

###################################
#regularized logistic regression with logloss calculation

glmnet.logit = glmnet(x = train, y = as.matrix(click), family = 'binomial', alpha = 0)
#plot(glmnet.logit, xvar = 'lambda', label = T)
cv = cv.glmnet(train, as.matrix(click), alpha = 0, nfolds = 5)

#clean up
#rm(train)

#####################################################################
#Prepare data for testing

test = select(test, -hour, -id)
test = sparse.model.matrix(~ . , test, contrasts.arg = c('C1', 'C15', 'C16', 'C18', 'actualhour', 'day'))

#################################
#Make prediction

prediction = predict(glmnet.logit, newx = test, type = 'response', s = cv$lambda.min)

#rm(test)

sample = read.csv('sampleSubmission', colClasses = c('id' = 'character'))
submit = cbind(sample[,1], prediction)
submit = data.frame(submit)
colnames(submit) = c('id', 'click')
write.csv(submit, file = 'kaggleclicklogit.csv', row.names = F, quote = F)