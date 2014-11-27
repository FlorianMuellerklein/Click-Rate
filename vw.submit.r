library(data.table)
library(plyr)
library(dplyr)
library(Matrix)

setwd("~/Documents/Kaggle/Click-Rate")
train = fread('train')
train = select(train, -id)
train = select(train, -id, -device_id, -device_ip

#calculate click ratio of entire dataset
click.ratio = sum(train[, click]) / nrow(train)

train$actualhour = as.character(substring(train$hour, 7,8))
train$day = weekdays(as.Date(strptime(as.character(train$hour), '%y%m%d %H')))

#Calculate click rates hour, day
#use the smoothing function alpha * beta / beta with a unique beta for each column 
#alpha = 0.17
#beta = 250

#calcute click rate per hour and add those rates to a new column in data

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

banner.ctr = train %>% group_by(banner_pos) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
banner.ctr = data.frame(banner.ctr)
for (i in unique(train$banner_pos)) {
    train$banner.ctr[train$banner_pos == i] = banner.ctr[banner.ctr$banner_pos == i, 'ratio']
}

site.ctr = train %>% group_by(site_category) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
site.ctr = data.frame(site.ctr)
for (i in unique(train$site_category)) {
    train$site.ctr[train$site_category == i] = site.ctr[site.ctr$site_category == i, 'ratio']
}

device.ctr = train %>% group_by(device_type) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
device.ctr = data.frame(device.ctr)
for (i in unique(train$device_type)) {
    train$device.ctr[train$device_type == i] = device.ctr[device.ctr$device_type == i, 'ratio']
}


train$C1 = as.character(train$C1)
train$banner_pos = as.character(train$banner_pos)
train$site_id = as.character(train$site_id)
train$site_domain = as.character(train$site_domain)
train$site_category = as.character(train$site_category)
train$app_id = as.character(train$app_id)
train$app_domain = as.character(train$app_domain)
train$app_category = as.character(train$app_category)
train$device_model = as.character(train$device_model)
train$device_type = as.character(train$device_type)
train$device_conn_type = as.character(train$device_conn_type)
train$C14 = as.character(train$C14)
train$C15 = as.character(train$C15)
train$C16 = as.character(train$C16)
train$C17 = as.character(train$C17)
train$C18 = as.character(train$C18)
train$C19 = as.character(train$C19)
train$C20 = as.character(train$C20)
train$C21 = as.character(train$C21)

train = select(train, -hour)

#################################
#Export train set to vowpal wabbit

outcomeName = 'click'
trainDF = data.frame(train)

#take all column names except for 'click'
predictors = names(trainDF)[!names(trainDF) %in% c(outcomeName, '')]

#Classes have to be either -1 or 1 for vowpal wabbit
trainDF[,outcomeName] = ifelse(trainDF[,outcomeName] > 0, 1, -1)
#add the '|' thing as per vowpal wabbit format
trainDF[,outcomeName] = paste(trainDF[,outcomeName], "|")

# reorder columns so that label (outcome) is first followed by predictors     
#click is already first so this is commented out
#trainDF  =  trainDF[c(outcomeName, predictors)]

write.table(trainDF, file = 'vw_train.txt', sep = " ", quote = F, row.names = F,  col.names = F) 

##################################
#Validate if format is right
#http://hunch.net/~vw/validate.html

##################################
#Run Vowpal Wabbit!
#type the two following commands in terminal

#vw -d vw_train.txt -c --passes 10 -f ctr.model.vw --loss_function logistic

#vw vw_test.txt -t -i ctr.model.vw -p ctr.preds.txt

rm(train, trainDF)

##################################
#Load and generate features for testing set
test = fread('test')

#calculate click ratio of entire dataset
click.ratio = sum(test[, click]) / nrow(test)

test$actualhour = as.character(substring(test$hour, 7,8))
test$day = weekdays(as.Date(strptime(as.character(test$hour), '%y%m%d %H')))

hour.ctr = data.frame(hour.ctr)
for (i in unique(test$actualhour)) {
    test$hour.ctr[test$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

#calcute click rate per day and add those rates to a new column in data
day.ctr = data.frame(day.ctr)
for (i in unique(test$day)) {
    test$day.ctr[test$day == i] = day.ctr[day.ctr$day == i, 'ratio']
}

rm(day.ctr, hour.ctr)

test$C1 = as.character(test$C1)
test$banner_pos = as.character(test$banner_pos)
test$device_type = as.character(test$device_type)
test$C14 = as.character(test$C14)
test$C15 = as.character(test$C15)
test$C16 = as.character(test$C16)
test$C17 = as.character(test$C17)
test$C18 = as.character(test$C18)
test$C19 = as.character(test$C19)
test$C20 = as.character(test$C20)
test$C21 = as.character(test$C21)

test = select(test, -hour)

#################################
#Export test set to vowpal wabbit

outcomeName = 'id'
testDF = data.frame(test)

#take all column names except for 'click'
predictors = names(testDF)[!names(testDF) %in% c(outcomeName, '')]

#Classes have to be either -1 or 1 for vowpal wabbit
#testDF[,outcomeName] = ifelse(testDF[,outcomeName] > 0, 1, -1)
#add the '|' thing as per vowpal wabbit format
testDF[,outcomeName] = paste(testDF[,outcomeName], "|")


# reorder columns so that label (outcome) is first followed by predictors     
#click is already first so this is commented out
#testDF  =  testDF[c(outcomeName, predictors)]

write.table(testDF, file = 'vw_test.txt', sep = " ", quote = F, row.names = F,  col.names = F)



###################################
#After VW is finished make submission file

#create a sigmoid function to convert VW output into probabilities
zigmoid = function(x) {
    return(1 / (1 + exp(-x)))
}

prediction = read.table('ctr.preds.txt', sep = ' ')

prediction = zigmoid(prediction)

sample = read.csv('sampleSubmission', colClasses = c('id' = 'character'))
submit = cbind(sample[,1], prediction)
submit = data.frame(submit)
colnames(submit) = c('id', 'click')
write.csv(submit, file = 'kagglevw.csv', row.names = F, quote = F)
