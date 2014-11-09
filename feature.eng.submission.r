library(plyr)
library(dplyr)
library(Matrix)
library(glmnet)

setwd("~/Documents/Kaggle/Click-Rate")
data = read.csv('saturday.train.csv')
data = select(data, click, hour, C21, C22, C24, C19, C18, app_category, site_category)

test = read.csv('test_rev2.csv')
test = select(test, id, hour, C21, C22, C24, C19, C18, app_category, site_category)
test.id = select(test, id)
test = select(test, -id)

###################################
#prepare data

#Put 1 in for values that don't exist in either set
test$C22 = ifelse(test$C22 %in% unique(data$C22), test$C22, 1)
test$C24 = ifelse(test$C24 %in% unique(data$C24), test$C24, 1)
test$app_category = ifelse(test$app_category %in% unique(data$app_category), test$app_category, 1)
test$site_category = ifelse(test$site_category %in% unique(data$site_category), test$site_category, 1)
test.C19 = ifelse(test$C19 %in% unique(data$C19), test$C19, 1)
test.C18 = ifelse(test$C18 %in% unique(data$C18), test$C18, 1)
test$C19 = test.C19
test$C19 = ifelse(test$C19 == 9, 8, test$C19)
test$C18 = test.C18
rm(test.C18, test.C19)

data$C22 = ifelse(data$C22 %in% unique(test$C22), data$C22, 1)
data$C24 = ifelse(data$C24 %in% unique(test$C24), data$C24, 1)
data$app_category = ifelse(data$app_category %in% unique(test$app_category), data$app_category, 1)
data$site_category = ifelse(data$site_category %in% unique(test$site_category), data$site_category, 1)
data.C19 = ifelse(data$C19 %in% unique(test$C19), data$C19, 1)
data.C18 = ifelse(data$C18 %in% unique(test$C18), data$C18, 1)
data$C19 = data.C19
data$C18 = data.C18
rm(data.C18, data.C19)

#factorize data
data$C21 = factor(data$C21)
data$C22 = factor(data$C22)
data$C24 = factor(data$C24)
data$C19 = factor(data$C19)
data$C18 = factor(data$C18)
data$app_category = factor(data$app_category)
data$site_category = factor(data$site_category)

test$C21 = factor(test$C21)
test$C22 = factor(test$C22)
test$C24 = factor(test$C24)
test$C19 = factor(test$C19)
test$C18 = factor(test$C18)
test$app_category = factor(test$app_category)
test$site_category = factor(test$site_category)

####################################
#Feature Engineering
####################################

#create variable of just the hours in a day
data$actualhour = as.character(substring(data$hour, 7,8))
test$actualhour = as.character(substring(test$hour, 7,8))

#Calculate click rates hour, C21, C22, C24, C19, C18, app_category, site_category
#use the smoothing function alpha * beta / beta with a unique beta for each column 

alpha = 0.14
beta = 250

#calcute click rate per hour and add those rates to a new column in data

hour.ctr = data %>% group_by(actualhour) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
hour.ctr = data.frame(hour.ctr)
for (i in unique(data$actualhour)) {
    data$hour.ctr[data$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
    test$hour.ctr[test$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

#calcute click rate per C21 and add those rates to a new column in data
C21.ctr = data %>% group_by(C21) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C21.ctr = data.frame(C21.ctr)
for (i in unique(data$C21)) {
    data$C21.ctr[data$C21 == i] = C21.ctr[C21.ctr$C21 == i, 'ratio']
    test$C21.ctr[test$C21 == i] = C21.ctr[C21.ctr$C21 == i, 'ratio']
}

#calcute click rate per C22 and add those rates to a new column in data
C22.ctr = data %>% group_by(C22) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C22.ctr = data.frame(C22.ctr)
for (i in unique(data$C22)) {
    data$C22.ctr[data$C22 == i] = C22.ctr[C22.ctr$C22 == i, 'ratio']
    test$C22.ctr[test$C22 == i] = C22.ctr[C22.ctr$C22 == i, 'ratio']
}

#calcute click rate per C24 and add those rates to a new column in data
C24.ctr = data %>% group_by(C24) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C24.ctr = data.frame(C24.ctr)
for (i in unique(data$C24)) {
    data$C24.ctr[data$C24 == i] = C24.ctr[C24.ctr$C24 == i, 'ratio']
    test$C24.ctr[test$C24 == i] = C24.ctr[C24.ctr$C24 == i, 'ratio']
}

#calcute click rate per C19 and add those rates to a new column in data
C19.ctr = data %>% group_by(C19) %>% summarise(ratio = sum(click ==1) / length(click))
C19.ctr = data.frame(C19.ctr)
for (i in unique(data$C19)) {
    data$C19.ctr[data$C19 == i] = C19.ctr[C19.ctr$C19 == i, 'ratio']
    test$C19.ctr[test$C19 == i] = C19.ctr[C19.ctr$C19 == i, 'ratio']
}

#calcute click rate per C18 and add those rates to a new column in data
C18.ctr = data %>% group_by(C18) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
C18.ctr = data.frame(C18.ctr)
for (i in unique(data$C18)) {
    data$C18.ctr[data$C18 == i] = C18.ctr[C18.ctr$C18 == i, 'ratio']
    test$C18.ctr[test$C18 == i] = C18.ctr[C18.ctr$C18 == i, 'ratio']
}

#calcute click rate per app_category and add those rates to a new column in data
app.ctr = data %>% group_by(app_category) %>% summarise(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta))
app.ctr = data.frame(app.ctr)
for (i in unique(data$app_category)) {
    data$app.ctr[data$app_category == i] = app.ctr[app.ctr$app_category == i, 'ratio']
    test$app.ctr[test$app_category == i] = app.ctr[app.ctr$app_category == i, 'ratio']
}

#calcute click rate per site_category and add those rates to a new column in data
site.ctr = data %>% group_by(site_category) %>% summarise(ratio = sum(ratio = (sum(click == 1) + (alpha * beta)) / (length(click) + beta)))
site.ctr = data.frame(site.ctr)
for (i in unique(data$site_category)) {
    data$site.ctr[data$site_category == i] = site.ctr[site.ctr$site_category == i, 'ratio']
    test$site.ctr[test$site_category == i] = site.ctr[site.ctr$site_category == i, 'ratio']
}

rm(C21.ctr, C22.ctr, C24.ctr, C19.ctr, C18.ctr, hour.ctr, site.ctr, app.ctr)

#put click in it's own variable for training later
click = data[,1]
data = select(data, -click)

#combine data and test before sparse so that each test has the exact same columns later
numdata = nrow(data)
data = rbind(data, test)
data = select(data, -hour)
rm(test)

#hours to numeric
data$actualhour = as.numeric(data$actualhour)

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
data.matrix = cbind(data[,8:16], data.matrix)
#data.matrix = data.frame(data.matrix)
rm(data)

#remove noise
data.matrix = select(data.matrix, -C221, -C241, -C191, -C181, -app_category1, -site_category1)

#put train and test back together
test.matrix = data.matrix[(numdata + 1):nrow(data.matrix),]
data.matrix = data.matrix[1:numdata, ]

#turn matrix into sparse
#data.matrix = sparse.model.matrix(~ ., data.matrix)
#test.matrix = sparse.model.matrix(~ ., test.matrix)

###################################
#Train logistic regression

#cv = cv.glmnet(as.matrix(data.matrix), as.matrix(click), nfolds = 10)
glmnet.logit = glmnet(x = as.matrix(data.matrix), y = as.matrix(click), family = 'binomial')

################################
#make prediction

#prediction = predict(cv, newx = as.matrix(test.matrix), type = 'response', s = cv$lambda.min)
prediction = predict(glmnet.logit, newx = as.matrix(test.matrix), type = 'response', s = 0.000005)

#getting an single NA somehow so replace it with avg click rate
prediction = ifelse(is.na(prediction), .14, prediction)

sample = read.csv('sampleSubmission.csv', colClasses = c('id' = 'character'))
submit = cbind(sample[,1], prediction)
submit = data.frame(submit)
colnames(submit) = c('id', 'click')
write.csv(submit, file = 'kaggleclicklogit.csv', row.names = F, quote = F)


#write csv for vowpal wabbit
test.matrix = cbind(test.id, test.matrix)
data.matrix = cbind(click, data.matrix)

write.csv(test.matrix, file = 'vw_test.csv', row.names = F, quote = F)
write.csv(data.matrix, file = 'vw_train.csv', row.names = F, quote = F)