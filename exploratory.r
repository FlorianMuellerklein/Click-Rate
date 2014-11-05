library(plyr)
library(dplyr)
library(ggplot2)

setwd('/Volumes/PSSD/FlashDrive/R/Click Rate')
data = read.csv('saturday.train.csv')
data = select(data, -X, -day)

#prepare data
data$click = factor(data$click)
data$C1 = factor(data$C1)
data$banner_pos = factor(data$banner_pos)
data$device_os = factor(data$device_os)
data$device_make = factor(data$device_make)
data$C21 = factor(data$C21)
data$device_type = factor(data$device_type)
data$device_conn_type = factor(data$device_conn_type)
data$device_geo_country = factor(data$device_geo_country)
data$C17 = factor(data$C17)
data$C18 = factor(data$C18)
data$C19 = factor(data$C19)
data$C20 = factor(data$C20)
data$C22 = factor(data$C22)
data$C23 = factor(data$C23)
data$C24 = factor(data$C24)

#create variable of just the hours in a day
data$actualhour = factor(substring(data$hour, 7,8))

#split data do randoforest to check importance
indices = sample(1:nrow(data), nrow(data)*.2)
rf.test = data[indices, ]
rf.test = select(rf.test, -site_id, -site_domain, -app_id, -device_id, -device_ip, -device_model, -device_make, -device_geo_country, -C17, -C20, -C23, -app_domain)
rf = randomForest(click ~ . , data = rf.test)

#click rate per hour
hour.ctr = data %>% group_by(actualhour) %>% summarise(ratio = sum(click == 1) / length(click))
ggplot(hour.ctr, aes(x = as.integer(actualhour), y = ratio)) + geom_line(color = 'dodgerblue3', size = 1.1) + theme_bw() + theme(panel.border = element_blank(), axis.line = element_line(color = 'black'))

#click rate per C21
C21.ctr = data %>% group_by(C21) %>% summarise(ratio = sum(click == 1) / length(click))
ggplot(C21.ctr, aes(x = as.integer(C21), y = ratio)) + geom_line(color = 'dodgerblue3', size = 1.1) + theme_bw() + theme(panel.border = element_blank(), axis.line = element_line(color = 'black'))

#click rate per C24
C24.ctr = data %>% group_by(C24) %>% summarise(ratio = sum(click == 1) / length(click))
ggplot(C24.ctr, aes(x = as.integer(C24), y = ratio)) + geom_line(color = 'dodgerblue3', size = 1.1) + theme_bw() + theme(panel.border = element_blank(), axis.line = element_line(color = 'black'))


#click rate per C22
C22.ctr = data %>% group_by(C22) %>% summarise(ratio = sum(click == 1) / length(click))
ggplot(C22.ctr, aes(x = as.integer(C22), y = ratio)) + geom_line(color = 'dodgerblue3', size = 1.1) + theme_bw() + theme(panel.border = element_blank(), axis.line = element_line(color = 'black'))

#C22 is so good?!?!
click = filter(data, click == 1)
noclick = filter(data, click == 0)

C22.click = select(click, C22, click)
C22.noclick = select(noclick, C22, noclick)