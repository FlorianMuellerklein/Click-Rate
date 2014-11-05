library(plyr)
library(dplyr)

setwd('/Volumes/PSSD/FlashDrive/R/Click Rate')
data = read.csv('saturday.train.csv')
data = select(data, hour, C21, C22, C24, click)

#prepare data
data$C21 = factor(data$C21, ordered = F)
data$C22 = factor(data$C22, ordered = F)
data$C24 = factor(data$C24, ordered = F)

#create variable of just the hours in a day
data$actualhour = factor(substring(data$hour, 7,8))

#####################################
#Logistic Regression
#formula = click ~ C21 + actualhour + banner_pos + device_conn_type + C1
#formula2 = click ~ device_type + C18 + C19 + C22 + C24 + site_category + app_category

click.logit = glm(click ~ C21 + actualhour + C22 + C24, data = data, family = 'binomial')

####################################
#Load test train
rm(data)

test = read.csv('test_rev2.csv')
sample = read.csv('sampleSubmission.csv', colClasses = c('id' = 'character'))

#test$C22 = ifelse(match(test$C22, unique(data$C22)), test$C22, NA)
#test$C24 = ifelse(match(test$C24, unique(data$C24)), test$C22, NA)

#prepare test train
#test$C21 = factor(test$C21, ordered = F)
#test$C22 = factor(test$C22, ordered = F)
#test$C24 = factor(test$C24, ordered = F)
test$actualhour = factor(substring(test$hour, 7,8))

test = select(test, C21, C22, C24, actualhour)

#make prediction
prediction = predict(click.logit, newdata = test, type = 'response', na.action = na.omit)
submit = cbind(sample[,1], prediction)
rm(test)
submit = data.frame(submit)
colnames(submit) = c('id', 'click')
write.csv(submit, file = 'kaggleclicklogit.csv', row.names = F, quote = F)
