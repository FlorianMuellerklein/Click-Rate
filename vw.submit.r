library(data.table)
library(plyr)
library(dplyr)
library(Matrix)

setwd("/Volumes/Mildred/Kaggle/Click-Rate")
train = fread('train')
train = select(train, -id, -device_id, -device_ip)

test = fread('test')
test = select(test, -id, -device_id, -device_ip)

#######################################
#Label Noise
train$banner_pos = ifelse(train$banner_pos %in% unique(test$banner_pos), train$banner_pos, 'Noise')
train$site_category = ifelse(train$site_category %in% unique(test$site_category), train$site_category, 'Noise')
train$app_domain = ifelse(train$app_domain %in% unique(test$app_domain), train$app_domain, 'Noise')
train$app_category = ifelse(train$app_category %in% unique(test$app_category), train$app_category, 'Noise')
train$device_type = ifelse(train$device_type %in% unique(test$device_type), train$device_type, 'Noise')
train$C17 = ifelse(train$C17 %in% unique(test$C17), train$C17, 'Noise')
train$C19 = ifelse(train$C19 %in% unique(test$C19), train$C19, 'Noise')
train$C20 = ifelse(train$C20 %in% unique(test$C20), train$C20, 'Noise')
train$C21 = ifelse(train$C21 %in% unique(test$C21), train$C21, 'Noise')

test$banner_pos = ifelse(test$banner_pos %in% unique(train$banner_pos), test$banner_pos, 'Noise')
test$site_category = ifelse(test$site_category %in% unique(train$site_category), test$site_category, 'Noise')
test$app_domain = ifelse(test$app_domain %in% unique(train$app_domain), test$app_domain, 'Noise')
test$app_category = ifelse(test$app_category %in% unique(train$app_category), test$app_category, 'Noise')
test$device_type = ifelse(test$device_type %in% unique(train$device_type), test$device_type, 'Noise')
test$C17 = ifelse(test$C17 %in% unique(train$C17), test$C17, 'Noise')
test$C19 = ifelse(test$C19 %in% unique(train$C19), test$C19, 'Noise')
test$C20 = ifelse(test$C20 %in% unique(train$C20), test$C20, 'Noise')
test$C21 = ifelse(test$C21 %in% unique(train$C21), test$C21, 'Noise')

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
day.ctr = train %>% group_by(day) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
day.ctr = data.frame(day.ctr)
banner.ctr = train %>% group_by(banner_pos) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
banner.ctr = data.frame(banner.ctr)
site.ctr = train %>% group_by(site_category) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
site.ctr = data.frame(site.ctr)
device.ctr = train %>% group_by(device_type) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
device.ctr = data.frame(device.ctr)
C1.ctr = train %>% group_by(C1) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C1.ctr = data.frame(C1.ctr)
C14.ctr = train %>% group_by(C14) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C14.ctr = data.frame(C14.ctr)
C15.ctr = train %>% group_by(C15) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C15.ctr = data.frame(C15.ctr)
C16.ctr = train %>% group_by(C16) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C16.ctr = data.frame(C16.ctr)
C17.ctr = train %>% group_by(C17) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C17.ctr = data.frame(C17.ctr)
C18.ctr = train %>% group_by(C18) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C18.ctr = data.frame(C18.ctr)
C19.ctr = train %>% group_by(C19) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C16.ctr = data.frame(C19.ctr)
C20.ctr = train %>% group_by(C20) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C20.ctr = data.frame(C20.ctr)
C21.ctr = train %>% group_by(C21) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C21.ctr = data.frame(C21.ctr)

for (i in unique(train$actualhour)) {
    train$hour.ctr[train$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

for (i in unique(train$day)) {
    train$day.ctr[train$day == i] = day.ctr[day.ctr$day == i, 'ratio']
}

for (i in unique(train$banner_pos)) {
    train$banner.ctr[train$banner_pos == i] = banner.ctr[banner.ctr$banner_pos == i, 'ratio']
}

for (i in unique(train$site_category)) {
    train$site.ctr[train$site_category == i] = site.ctr[site.ctr$site_category == i, 'ratio']
}

for (i in unique(train$device_type)) {
    train$device.ctr[train$device_type == i] = device.ctr[device.ctr$device_type == i, 'ratio']
}

for (i in unique(train$C1)) {
    train$C1.ctr[train$C1 == i] = C1.ctr[C1.ctr$C1 == i, 'ratio']
}

for (i in unique(train$C14)) {
    train$C14.ctr[train$C14 == i] = C14.ctr[C14.ctr$C14 == i, 'ratio']
}

for (i in unique(train$C15)) {
    train$C15.ctr[train$C15 == i] = C15.ctr[C15.ctr$C15 == i, 'ratio']
}

for (i in unique(train$C16)) {
    train$C16.ctr[train$C16 == i] = C16.ctr[C16.ctr$C16 == i, 'ratio']
}

for (i in unique(train$C17)) {
    train$C17.ctr[train$C17 == i] = C17.ctr[C17.ctr$C17 == i, 'ratio']
}

for (i in unique(train$C18)) {
    train$C18.ctr[train$C18 == i] = C18.ctr[C18.ctr$C18 == i, 'ratio']
}

for (i in unique(train$C19)) {
    train$C19.ctr[train$C19 == i] = C19.ctr[C19.ctr$C19 == i, 'ratio']
}

for (i in unique(train$C20)) {
    train$C20.ctr[train$C20 == i] = C20.ctr[C20.ctr$C20 == i, 'ratio']
}

for (i in unique(train$C21)) {
    train$C21.ctr[train$C21 == i] = C21.ctr[C21.ctr$C21 == i, 'ratio']
}

train$avg.ctr = rowMeans(train[, 24:34, with = F])

ttrain$C1 = as.character(train$C1)
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
train = data.frame(train)

#take all column names except for 'click'
predictors = names(train)[!names(train) %in% c(outcomeName, '')]
cat.predictors = predictors[1:21]
cont.predictors = predictors[22:33]

click.backup = train[, outcomeName]
#Classes have to be either -1 or 1 for vowpal wabbit
train[,outcomeName] = ifelse(train[,outcomeName] == 0, -1, 1)
#add the '|' thing as per vowpal wabbit format
train[,outcomeName] = paste(train[,outcomeName], "|c")

for (i in cat.predictors) {
    train[,i] = paste0(i, train[,i], sep = '')
}

for (i in cont.predictors) {
    train[,i] = paste0(i, ':', train[,i], sep = '')
}

for (i in cont.predictors[1]) {
    train[,i] = paste0('|i ', train[,i], sep = ' ')
}

# reorder columns so that label (outcome) is first followed by predictors     
#click is already first so this is commented out
#trainDF  =  trainDF[c(outcomeName, predictors)]

write.table(train, file = 'vw_train.avgctr.txt', sep = " ", quote = F, row.names = F,  col.names = F) 

##################################
#Validate if format is right
#http://hunch.net/~vw/validate.html

##################################
#Run Vowpal Wabbit!
#type the two following commands in terminal

#find optimal regularization values
#vw-hypersearch 1e-10 1 vw --l1 --loss_function logistic % vw_trainnew.txt
#vw-hypersearch 1e-10 1 vw --l2 --loss_function logistic % vw_trainnew.txt

#vw -d vw_trainnew.txt -c -k --passes 20 -b 29 -f ctr.model.new.vw --loss_function logistic --learning_rate 0.1

#vw vw_test.txt -t -i ctr.model.vw -p ctr.preds.txt

#rm(train, trainDF)

##################################
#Load and generate features for testing set
test.id = fread('test')
test = select(test, -device_id, -device_ip)

test$actualhour = as.character(substring(test$hour, 7,8))
test$day = weekdays(as.Date(strptime(as.character(test$hour), '%y%m%d %H')))

for (i in unique(test$actualhour)) {
    test$hour.ctr[test$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

#calcute click rate per day and add those rates to a new column in data
for (i in unique(test$day)) {
    test$day.ctr[test$day == i] = day.ctr[day.ctr$day == i, 'ratio']
}

for (i in unique(test$banner_pos)) {
    test$banner.ctr[test$banner_pos == i] = banner.ctr[banner.ctr$banner_pos == i, 'ratio']
}

for (i in unique(test$site_category)) {
    test$site.ctr[test$site_category == i] = site.ctr[site.ctr$site_category == i, 'ratio']
}

for (i in unique(test$device_type)) {
    test$device.ctr[test$device_type == i] = device.ctr[device.ctr$device_type == i, 'ratio']
}

for (i in unique(test$C1)) {
    test$C1.ctr[test$C1 == i] = C1.ctr[C1.ctr$C1 == i, 'ratio']
}

for (i in unique(test$C14)) {
    test$C14.ctr[test$C14 == i] = C14.ctr[C14.ctr$C14 == i, 'ratio']
}

for (i in unique(test$C15)) {
    test$C15.ctr[test$C15 == i] = C15.ctr[C15.ctr$C15 == i, 'ratio']
}

for (i in unique(test$C16)) {
    test$C16.ctr[test$C16 == i] = C16.ctr[C16.ctr$C16 == i, 'ratio']
}

for (i in unique(test$C17)) {
    test$C17.ctr[test$C17 == i] = C17.ctr[C17.ctr$C17 == i, 'ratio']
}

for (i in unique(test$C18)) {
    test$C18.ctr[test$C18 == i] = C18.ctr[C18.ctr$C18 == i, 'ratio']
}

for (i in unique(test$C19)) {
    test$C19.ctr[test$C19 == i] = C19.ctr[C19.ctr$C19 == i, 'ratio']
}

for (i in unique(test$C20)) {
    test$C20.ctr[test$C20 == i] = C20.ctr[C20.ctr$C20 == i, 'ratio']
}

for (i in unique(test$C21)) {
    test$C21.ctr[test$C21 == i] = C21.ctr[C21.ctr$C21 == i, 'ratio']
}

test$avg.ctr = rowMeans(test[, 23:34, with = F])

test$C1 = as.character(test$C1)
test$banner_pos = as.character(test$banner_pos)
test$site_id = as.character(test$site_id)
test$site_domain = as.character(test$site_domain)
test$site_category = as.character(test$site_category)
test$app_id = as.character(test$app_id)
test$app_domain = as.character(test$app_domain)
test$app_category = as.character(test$app_category)
test$device_model = as.character(test$device_model)
test$device_type = as.character(test$device_type)
test$device_conn_type = as.character(test$device_conn_type)
test$C14 = as.character(test$C14)
test$C15 = as.character(test$C15)
test$C16 = as.character(test$C16)
test$C17 = as.character(test$C17)
test$C18 = as.character(test$C18)
test$C19 = as.character(test$C19)
test$C20 = as.character(test$C20)
test$C21 = as.character(test$C21)

test = select(test, -hour)
test = data.frame(test)

#################################
#Export test set to vowpal wabbit

outcomeName = 'id'
predictors = names(test)[!names(test) %in% c(outcomeName, '')]
cat.predictors = predictors[1:21]
cont.predictors = predictors[22:34]

test$id = paste(test$id, "|c")

for (i in cat.predictors) {
    test[,i] = paste0(i, test[,i], sep = '')
}

for (i in cont.predictors) {
    test[,i] = paste0(i, ':', test[,i], sep = '')
}

for (i in cont.predictors[1]) {
    test[,i] = paste0('|i ', test[,i], sep = ' ')
}

# reorder columns so that label (outcome) is first followed by predictors     
#click is already first so this is commented out
#testDF  =  testDF[c(outcomeName, predictors)]

write.table(test, file = 'vw_test.avgctr.txt', sep = " ", quote = F, row.names = F,  col.names = F)

###################################
#After VW is finished make submission file

#create a sigmoid function to convert VW output into probabilities
zigmoid = function(x) {
    return(1 / (1 + exp(-x)))
}

prediction = read.table('ctr.preds.new.txt', sep = ' ')

prediction = zigmoid(prediction)

sample = read.csv('sampleSubmission', colClasses = c('id' = 'character'))
submit = cbind(sample[,1], prediction)
submit = data.frame(submit)
colnames(submit) = c('id', 'click')
write.csv(submit, file = 'kagglevwnew.csv', row.names = F, quote = F)
