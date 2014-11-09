library(plyr)
library(dplyr)

setwd('/Volumes/PSSD/FlashDrive/R/Click Rate')
data = read.csv('saturday.train.csv')
data = select(data, hour, C21, C22, C24, click, C19, C18, app_category, site_category)

test = read.csv('test_rev2.csv')
test = select(test, hour, C21, C22, C24, C19, C18, app_category, site_category)

#Put 0 in for values that don't exist in either set
test$C22 = ifelse(test$C22 %in% unique(data$C22), test$C22, 1)
test$C24 = ifelse(test$C24 %in% unique(data$C24), test$C24, 1)
test.C19 = ifelse(test$C19 %in% unique(data$C19), test$C19, 1)
test.C18 = ifelse(test$C18 %in% unique(data$C18), test$C18, 1)
test$C19 = test.C19
test$C19 = ifelse(test$C19 == 9, 8, test$C19)
test$C18 = test.C18
rm(test.C18, test.C19)

data$C22 = ifelse(data$C22 %in% unique(test$C22), data$C22, 1)
data$C24 = ifelse(data$C24 %in% unique(test$C24), data$C24, 1)
data.C19 = ifelse(data$C19 %in% unique(test$C19), data$C19, 1)
data.C18 = ifelse(data$C18 %in% unique(test$C18), data$C18, 1)
data$C19 = data.C19
data$C18 = data.C18
rm(data.C18, data.C19)


#test = big.data[(drow+1):(nrow(big.data)),]
#rm(big.data)

#prepare data
data$C21 = factor(data$C21, ordered = F)
data$C22 = factor(data$C22, ordered = F)
data$C24 = factor(data$C24, ordered = F)
data$C19 = factor(data$C19, ordered = F)
data$C18 = factor(data$C18, ordered = F)
data$app_category = factor(data$app_category, ordered = F)
data$site_category = factor(data$site_category, ordered = F)
#create variable of just the hours in a day
data$actualhour = factor(substring(data$hour, 7,8))

colnames(test) = c('hour', 'C21', 'C22', 'C24', 'C19', 'C18', 'app_category', 'site_category')
test$C21 = factor(test$C21, ordered = F)
test$C22 = factor(test$C22, ordered = F)
test$C24 = factor(test$C24, ordered = F)
test$C19 = factor(test$C19, ordered = F)
test$C18 = factor(test$C18, ordered = F)
test$app_category = factor(test$app_category, ordered = F)
test$site_category = factor(test$site_category, ordered = F)
#create variable of just the hours in a day
test$actualhour = factor(substring(test$hour, 7,8))

###################################
#Logistic Regression CV with logloss calculation

#indices = sample(1:nrow(data), nrow(data) * .8)
#train.cv = data[indices, ]
#test.cv = data[-indices, ]

#click.logit = glm(click ~ C21 + actualhour + C22 + C24 + app_category + site_category + C19 + C18 + C19nc + C18nc + appnc + sitenc, data = train.cv, family = 'binomial')

#prediction = predict(click.logit, newdata = test.cv, type = 'response')
#actual = test.cv$click


#llfun <- function(actual, prediction) {
#    epsilon <- .000000000000001
#    yhat <- pmin(pmax(prediction, epsilon), 1-epsilon)
#    logloss <- -mean(actual*log(yhat)
#                     + (1-actual)*log(1 - yhat))
#    return(logloss)
#}


#llfun(actual, prediction)

#0.382696!!!!!
#Make submission
rm(test.cv, train.cv, actual, prediction, indices, click.logit)

gc()
click.logit = glm(click ~ C21 + actualhour + C22 + C24 + app_category + site_category + C19 + C18, data = data, family = 'binomial')

sample = read.csv('sampleSubmission.csv', colClasses = c('id' = 'character'))
prediction = predict(click.logit, newdata = test, type = 'response')
submit = cbind(sample[,1], prediction)
rm(test)
submit = data.frame(submit)
colnames(submit) = c('id', 'click')
write.csv(submit, file = 'kaggleclicklogit.csv', row.names = F, quote = F)
