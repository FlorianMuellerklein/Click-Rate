library(data.table)
library(plyr)
library(dplyr)

setwd("~/Documents/Kaggle/Click-Rate")
data = fread('train_rev2')

#calculate click ratio of entire dataset
click.ratio = sum(data[, click]) / nrow(data)

data$actualhour = as.character(substring(data$hour, 7,8))
data$day = weekdays(as.Date(strptime(as.character(data$hour), '%y%m%d %H')))

#Calculate click rates hour, C21, C22, C24, C19, C18, app_category, site_category
#use the smoothing function alpha * beta / beta with a unique beta for each column 
alpha = 0.17
beta = 250

#calcute click rate per hour and add those rates to a new column in data

hour.ctr = data %>% group_by(actualhour) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
hour.ctr = data.frame(hour.ctr)
for (i in unique(data$actualhour)) {
    data$hour.ctr[data$actualhour == i] = hour.ctr[hour.ctr$actualhour == i, 'ratio']
}

#calcute click rate per C21 and add those rates to a new column in data
C21.ctr = data %>% group_by(C21) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C21.ctr = data.frame(C21.ctr)
for (i in unique(data$C21)) {
    data$C21.ctr[data$C21 == i] = C21.ctr[C21.ctr$C21 == i, 'ratio']
}

#calcute click rate per C22 and add those rates to a new column in data
C22.ctr = data %>% group_by(C22) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C22.ctr = data.frame(C22.ctr)
for (i in unique(data$C22)) {
    data$C22.ctr[data$C22 == i] = C22.ctr[C22.ctr$C22 == i, 'ratio']
}

#calcute click rate per C24 and add those rates to a new column in data
C24.ctr = data %>% group_by(C24) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C24.ctr = data.frame(C24.ctr)
for (i in unique(data$C24)) {
    data$C24.ctr[data$C24 == i] = C24.ctr[C24.ctr$C24 == i, 'ratio']
}

#calcute click rate per C19 and add those rates to a new column in data
C19.ctr = data %>% group_by(C19) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C19.ctr = data.frame(C19.ctr)
for (i in unique(data$C19)) {
    data$C19.ctr[data$C19 == i] = C19.ctr[C19.ctr$C19 == i, 'ratio']
}

#calcute click rate per C18 and add those rates to a new column in data
C18.ctr = data %>% group_by(C18) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
C18.ctr = data.frame(C18.ctr)
for (i in unique(data$C18)) {
    data$C18.ctr[data$C18 == i] = C18.ctr[C18.ctr$C18 == i, 'ratio']
}

#calcute click rate per app_category and add those rates to a new column in data
app.ctr = data %>% group_by(app_category) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
app.ctr = data.frame(app.ctr)
for (i in unique(data$app_category)) {
    data$app.ctr[data$app_category == i] = app.ctr[app.ctr$app_category == i, 'ratio']
}

#calcute click rate per site_category and add those rates to a new column in data
site.ctr = data %>% group_by(site_category) %>% summarise(ratio = (sum(click == 1) + (.17 * 250)) / (length(click) + 250))
site.ctr = data.frame(site.ctr)
for (i in unique(data$site_category)) {
    data$site.ctr[data$site_category == i] = site.ctr[site.ctr$site_category == i, 'ratio']
}

rm(C21.ctr, C22.ctr, C24.ctr, C19.ctr, C18.ctr, hour.ctr, site.ctr, app.ctr)