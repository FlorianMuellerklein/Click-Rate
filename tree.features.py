import pandas as pd
import sklearn as sk

from sklearn.ensemble import RandomTreesEmbedding
from sklearn.linear_model import SGDClassifier

######################################################
# load training data as a pandas file and then split up the click column from main

train = pd.read_csv('fresh.gbm.train.csv', header = 0)
click = train['click']
train = train.drop('click', 1)

################
# treat all variables as categorical

train['C1'] = pd.Categorical.from_array(train['C1']).codes
train['banner_pos'] = pd.Categorical.from_array(train['banner_pos']).codes
train['site_category'] = pd.Categorical.from_array(train['site_category']).codes
train['app_domain'] = pd.Categorical.from_array(train['app_domain']).codes
train['app_category'] = pd.Categorical.from_array(train['app_category']).codes
train['device_type'] = pd.Categorical.from_array(train['device_type']).codes
train['device_conn_type'] = pd.Categorical.from_array(train['device_conn_type']).codes
train['C15'] = pd.Categorical.from_array(train['C15']).codes
train['C16'] = pd.Categorical.from_array(train['C16']).codes
train['C17'] = pd.Categorical.from_array(train['C17']).codes
train['C18'] = pd.Categorical.from_array(train['C18']).codes
train['C19'] = pd.Categorical.from_array(train['C19']).codes
train['C20'] = pd.Categorical.from_array(train['C20']).codes
train['C21'] = pd.Categorical.from_array(train['C21']).codes
train['day'] = pd.Categorical.from_array(train['day']).codes
train['actualhour'] = pd.Categorical.from_array(train['actualhour']).codes
train['site_id'] = pd.Categorical.from_array(train['site_id']).codes
train['site_domain'] = pd.Categorical.from_array(train['site_domain']).codes
train['device_model'] = pd.Categorical.from_array(train['device_model']).codes
train['app_id'] = pd.Categorical.from_array(train['app_id']).codes
train['gbm'] = pd.Categorical.from_array(train['gbm']).codes
train['avg.ctr'] = pd.Categorical.from_array(train['avg.ctr']).codes

##################
# use the decision tree embedding trick from the Facebook paper

rfembed = RandomTreesEmbedding(n_estimators = 10, max_depth = 5, n_jobs = -1, verbose = 1)
embedded = rfembed.fit_transform(train)

##################
# train a gradient descent logistic regression classifier, similar to the vowpal wabbit one

logitsgd = SGDClassifier(loss='log', n_iter = 5, alpha = .0001, penalty='l2', n_jobs = -1)
logitmodel = logitsgd.fit(embedded, click)

#######################################################
# load the testing data

test = pd.read_csv('fresh.gbm.test.csv', header = 0)
id = test['id']
test= test.drop('id', 1)

################
# treat all variables as categorical

test['C1'] = pd.Categorical.from_array(test['C1']).codes
test['banner_pos'] = pd.Categorical.from_array(test['banner_pos']).codes
test['site_category'] = pd.Categorical.from_array(test['site_category']).codes
test['app_domain'] = pd.Categorical.from_array(test['app_domain']).codes
test['app_category'] = pd.Categorical.from_array(test['app_category']).codes
test['device_type'] = pd.Categorical.from_array(test['device_type']).codes
test['device_conn_type'] = pd.Categorical.from_array(test['device_conn_type']).codes
test['C15'] = pd.Categorical.from_array(test['C15']).codes
test['C16'] = pd.Categorical.from_array(test['C16']).codes
test['C17'] = pd.Categorical.from_array(test['C17']).codes
test['C18'] = pd.Categorical.from_array(test['C18']).codes
test['C19'] = pd.Categorical.from_array(test['C19']).codes
test['C20'] = pd.Categorical.from_array(test['C20']).codes
test['C21'] = pd.Categorical.from_array(test['C21']).codes
test['day'] = pd.Categorical.from_array(test['day']).codes
test['actualhour'] = pd.Categorical.from_array(test['actualhour']).codes
test['site_id'] = pd.Categorical.from_array(test['site_id']).codes
test['site_domain'] = pd.Categorical.from_array(test['site_domain']).codes
test['device_model'] = pd.Categorical.from_array(test['device_model']).codes
test['app_id'] = pd.Categorical.from_array(test['app_id']).codes
test['gbm'] = pd.Categorical.from_array(test['gbm']).codes
test['avg.ctr'] = pd.Categorical.from_array(test['avg.ctr']).codes

##################
# use the decision tree embedding trick from the Facebook paper

test_embed = rfembed.fit_transform(test)

##########################################################
# MAKE PREDICTIONS I DON'T EVEN KNOW IF THIS WILL WORK ;ASLKDJFAK;LSDJF ;LAKSDJF;ASLDKFJ 

prediction = logitmodel.predict(test_embed)

# HOW DO I WRITE PREDICITONS TO FILE?!?!?!?!
