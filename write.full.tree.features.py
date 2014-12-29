import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestClassifier

SEED = 80085
train_loc = 'train.day.hour.csv'
test_loc = 'test.day.hour.csv'

# load and prepare model fit data
def load_fit_data(path):
	fit_x = pd.read_csv(path, dtype = str, nrows = 500)
	fit_y = fit_x['click'].astype(int).values
	fit_x = fit_x.drop('click', 1)
	fit_x = fit_x.drop('id', 1)
	for colname in list(fit_x.columns.values):
		fit_x[colname] = pd.Categorical.from_array(fit_x[colname]).codes
		
	fit_x = fit_x.values
	
	return fit_x, fit_y

# load and prepare training data
def load_train_data(path, rf):
	reader = pd.read_csv(path, dtype = str, chunksize = 10000)
	for chunk in reader:
		click = chunk['click'].astype(int)
		chunk = chunk.drop('click', 1)
		chunk = chunk.drop('id', 1)
        orig = []
        for colname in list(chunk.columns.values):
            orig.append(colname + chunk[colname])
            chunk[colname] = pd.Categorical.from_array(chunk[colname]).codes
			
        chunk = chunk.values
        orig = np.column_stack(orig)

        train_rf = rf.apply(chunk).astype(str)
        for row in range(0, chunk.shape[0]):
		for column in range(0,30, 1):
			train_rf[row,column] = ('C' + str(column) + str(train_rf[row,column]))

        click = vw_ready(click)
        train_rf = np.column_stack((click, orig, train_rf))
		
        file_handle = file('train.tree.txt', 'a')
        np.savetxt(file_handle, train_rf, delimiter = ' ', fmt = '%s')
        file_handle.close()


# load and prepare testing data	
def load_test_data(path, rf):
	reader = pd.read_csv(path, dtype = str, chunksize = 10000)
	for chunk in reader:	
		id = chunk['id'].astype(str)
		chunk = chunk.drop('id', 1)
        orig = []
        for colname in list(chunk.columns.values):
            orig.append(colname + chunk[colname])
            chunk[colname] = pd.Categorical.from_array(chunk[colname]).codes
			
        chunk = chunk.values
        orig = np.column_stack(orig)

        test_rf = rf.apply(chunk).astype(str)
        for row in range(0, chunk.shape[0]):
		for column in range(0,30, 1):
			test_rf[row,column] = ('C' + str(column) + str(test_rf[row,column]))
		
        id = vw_ready(id)
        test_rf = np.column_stack((id, orig, test_rf))
		
        file_handle = file('test.tree.txt', 'a')
        np.savetxt(file_handle, test_rf, delimiter = ' ', fmt = '%s')
        file_handle.close()


# add | to first column of output file so that the text files are ready for vw	
def vw_ready(data):
	data[data == 0] = -1
	data = (data.astype(str) + ' |c').as_matrix()
	
	return data
	
def main():
	# initialize sklearn objects
	rf = RandomForestClassifier(n_estimators = 30, max_depth = 7, verbose = 1, random_state = SEED)
	
	print('loading fit data ... ')
	fit_x, fit_y = load_fit_data(train_loc)
	
	# rf feature transformation
	print('fitting data ... ')
	rf.fit(fit_x, fit_y)
	fit_x = None
	fit_y = None
	
	print('writing training file with tree features ... ')
	load_train_data(train_loc, rf)
	
	print('writing test file with tree features ... ')
	load_test_data(test_loc, rf)
	
	
if __name__ == '__main__':
	main()
