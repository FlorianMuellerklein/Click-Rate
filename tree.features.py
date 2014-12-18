import pandas as pd
import sklearn as sk
import numpy as np

from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import SGDClassifier

train_loc = 'train.day.hour.csv'
test_loc = 'test.day.hour.csv'

#def load_train_data(path):
train = pd.read_csv(train_loc, dtype = str)
click = train['click']
train = train.drop('click', 1)
train = train.drop('id', 1)
for colname in list(train.columns.values):
	train[colname] = pd.Categorical.from_array(train[colname]).codes
	
#return train, click
	
def load_test_data(path):
	test = pd.read_csv(path)
	id = test['id']
	test = test.drop('id', 1)

# ~~~~~~~~~~~~~~~~~~~~~~~~ strong independent python script to load data ~~~~~~~~~~~~~~~~~~~~~~~

#load_train_data(train_loc)

rf = RandomForestClassifier(n_estimators = 500, max_depth = 3, verbose = 1, random_state = 80085)
rf.fit(train, click)
embedded = rf.apply(train)

train = None

# ~~~~~~~~~~~~~~~~~~~~~~~~ strong independent python script to do logit ~~~~~~~~~~~~~~~~~~~~~~~

logitsgd = SGDClassifier(loss='log', n_iter = 10, alpha=.003, penalty = 'l2', n_jobs = -1, verbose = 1)
logitmodel = logitsgd.fit(X = embedded, y = click)
