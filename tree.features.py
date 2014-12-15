import pandas as pd
import sklearn as sk

from sklearn.ensemble import RandomTreesEmbedding

# open csv file as a python object
#train_csv = csv.reader(open('fresh.gbm.train.csv', 'rb'))
#header = train_csv.next() 

train = pd.read_csv('fresh.gbm.train.csv', header = 0)
#for row in train_csv:
#	train.append(row)
#train = pandas.DataFrame(train)
click = train['click']
train = train.drop('click', 1)

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

rfembed = RandomTreesEmbedding(n_estimators = 10, max_depth = 5, n_jobs = -1, verbose = 1)

embedded = rfembed.fit_transform(train)

embedded = pd.DataFrame(embedded)

embedded.to_csv('embedded.csv')

embedded.head(10)
