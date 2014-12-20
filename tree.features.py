import pandas as pd
import sklearn as sk
import numpy as np

from csv import DictReader
from scipy.sparse import vstack
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import OneHotEncoder
from sklearn.linear_model import SGDClassifier

SEED = 80085
train_loc = 'train.day.hour.csv'
test_loc = 'test.day.hour.csv'

# load and prepare training data
def load_train_data(path):
	train = pd.read_csv(path, dtype = str, nrows = 4000000, low_memory = False)
	click = train['click'].astype(int)
	train = train.drop('click', 1)
	train = train.drop('id', 1)
	for colname in list(train.columns.values):
		train[colname] = pd.Categorical.from_array(train[colname]).codes
	
	return train, click

# load and prepare testing data	
def load_test_data(path):
	test = pd.read_csv(path, dtype = str, low_memory = False)
	test = test.drop('id', 1)
	for colname in list(test.columns.values):
		test[colname] = pd.Categorical.from_array(test[colname]).codes
	
	return test
	
def main():
	# initialize sklearn objects
	rf = RandomForestClassifier(n_estimators = 300, max_depth = 3, verbose = 1, random_state = SEED)
	logitsgd = SGDClassifier(loss ='log', n_jobs = -1, verbose = 1)
	encoder = OneHotEncoder()
	
	train, click = load_train_data(train_loc)
	
	# rf feature transformation
	rf.fit(train, click)
	train_rf = rf.apply(train)
	train = None
	
	# encode rf features for logit
	print('fitting encoder ... ')
	encoder.fit(train_rf)
	print('transforming ...')
	embedded = []
	for row in train_rf:
		embedded = vstack((embedded, encoder.transform(row)))
	
	train_rf = None
	
	# train model
	logitsgd.fit(X = embedded, y = click)
	embedded = None
	
	# load testing data
	test = load_test_data(test_loc)
	
	# rf transform test
	test_rf = rf.apply(test)
	test = None
	
	# encode test
	print('transforming ...')
	embedded = []
	for row in test_rf:
		embedded = vstack((embedded, encoder.transform(row)))
	
	test_rf = None
	
	# make predictions
	prediction = logitsgd.predict_proba(embedded_test)
	
	# save predictions
	prediction = np.array(prediction)
	np.savetxt("predictions.csv", prediction, delimiter = ",")
	
if __name__ == '__main__':
	main()
