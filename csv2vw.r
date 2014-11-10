library(dplyr)
setwd("~/Documents/Kaggle/Click-Rate")

test = read.csv('vw_test.csv')
train = read.csv('vw_train.csv')

outcomeName = 'click'
testlabel = 'id'
trainDF = train
testDF = test

#take all column names except for 'click'
predictors = names(train)[!names(train) %in% c(outcomeName, '')]
test.predictors = names(test)[!names(test) %in% c(testlabel, '')]

#Classes have to be either -1 or 1 for vowpal wabbit
trainDF[,outcomeName] = ifelse(trainDF[,outcomeName] > 0, paste(1, 2, 'click', sep = ' '), paste(-1, 1, 'no-click', sep = ' '))
#add the '|' thing as per vowpal wabbit format
trainDF[,outcomeName] = paste(trainDF[,outcomeName], "|")
testDF[,testlabel] = paste(testDF[,testlabel], "|")

testDF = select(testDF, -app.ctr, -site.ctr)
trainDF = select(trainDF, -app.ctr, -site.ctr)

#Pairing column names with data... adding 1 blank character before each variable
for (i in predictors) {
    trainDF[,i]  =  ifelse(trainDF[,i] == 1, paste0(' ',i),
                        ifelse(trainDF[,i] == 0,'',paste0(' ', i,':', trainDF[,i])))
}

for (i in test.predictors) {
    testDF[,i]  =  ifelse(testDF[,i] == 1, paste0(' ',i),
                           ifelse(testDF[,i] == 0,'',paste0(' ', i,':', testDF[,i])))
}

# reorder columns so that label (outcome) is first followed by predictors     
#click is already first so this is commented out
#trainDF  =  trainDF[c(outcomeName, predictors)]

write.table(trainDF, file = 'vw_train.txt', sep = "", quote = F, row.names = F,  col.names = F)
write.table(testDF, file = 'vw_test.txt', sep = "", quote = F, row.names = F,  col.names = F)

##################################
#Validate if format is right
#http://hunch.net/~vw/validate.html

##################################
#Run Vowpal Wabbit!
##################################

###################################
#After VW is finished make submission file

#create a sigmoid function to convert VW output into probabilities
zigmoid = function(x) {
    return(1 / (1 + exp(-x)))
}

prediction = read.table('ctr.preds.txt', sep = ' ')

prediction = zigmoid(prediction)

sample = read.csv('sampleSubmission.csv', colClasses = c('id' = 'character'))
submit = cbind(sample[,1], prediction)
submit = data.frame(submit)
colnames(submit) = c('id', 'click')
write.csv(submit, file = 'kagglevw.csv', row.names = F, quote = F)

