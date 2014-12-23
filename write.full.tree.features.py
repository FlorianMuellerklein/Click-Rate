import csv
import pandas as pd
import sklearn as sk
import numpy as np

from sklearn.ensemble import RandomForestClassifier

class littleBadBoy(object):
    """ 
    This here is a jabroni sandwhich
    """
    
    def __init__(self, fit_x, reader, SEED, path, rf, data):
        self.fit_x = fit_x
        self.fit_y = []
        
        self.reader = reader
        self.chunk = []
        self.train_rf = []
        self.click = []
        
        self.id = []
        self.test_rf = []
        
        self.SEED = SEED
        self.path = path
        self.rf = rf
        self.data = data
        
    def getFit_x(self):
        return self.fit_x
        
    def getSEED(self):
        return self.SEED
        
    def load_fit_data(self):
        """
        Model fit skeleton: load and prepare model fit data
        """
    	self.fit_y = self.fit_x['click'].astype(int)
    	self.fit_x = self.fit_x.drop('click', 1)
    	self.fit_x = self.fit_x.drop('id', 1)
    	for colname in list(self.fit_x.columns.values):
    		self.fit_x[colname] = pd.Categorical.from_array(self.fit_x[colname]).codes
        
    def load_train_data(self):
        """
        Model fit skeleton: load and prepare training data
        """
    	for self.chunk in self.reader:
    		self.click = self.chunk['click'].astype(int)
    		self.chunk = self.chunk.drop('click', 1)
    		self.chunk = self.chunk.drop('id', 1)
    		for colname in list(self.chunk.columns.values):
    			self.chunk[colname] = pd.Categorical.from_array(self.chunk[colname]).codes

    		self.train_rf = rf.apply(chunk)
    		self.click = vw_ready(click)
    		self.train_rf = np.column_stack((click, train_rf))
		
    		file_handle = file('train.tree.txt', 'a')
    		np.savetxt(file_handle, self.train_rf, delimiter = ' ', fmt = '%s')
    		file_handle.close()
        
    def load_test_data(self):
        """
        Model fit skeleton: load and prepare testing data
        """
       	for self.chunk in self.reader:	
       		self.id = self.chunk['id'].astype(str)
       		self.chunk = self.chunk.drop('id', 1)
       		for colname in list(self.chunk.columns.values):
       			self.chunk[colname] = pd.Categorical.from_array(self.chunk[colname]).codes

       		self.test_rf = rf.apply(self.chunk)
       		self.id = vw_ready(self.id)
       		self.test_rf = np.column_stack((self.id, test_rf))
	
       		file_handle = file('test.tree.txt', 'a')
       		np.savetxt(file_handle, test_rf, delimiter = ' ', fmt = '%s')
       		file_handle.close()
        
    def vw_ready(self):
        """
        Adds | to first col of data - prepare text files for VW
        """
    	self.data[self.data == 0] = -1
    	self.data = (data.astype(str) + ' |c').as_matrix()
        
    def __str__(self):
        """ 
        Print to screen variables
        """
        return "fit_x: %s\n seed: %s \n " % (self.fit_x, self.SEED)
        
	
def main():
    # Some opening bullshit lol
    SEED = 80085
    train_loc = 'train.day.hour.csv'
    test_loc = 'test.day.hour.csv'
    
    fit_x = pd.read_csv(path, dtype = str, nrows = 6000000, low_memory = False)
    reader = pd.read_csv(path, dtype = str, chunksize = 3000000, low_memory = False)
    
	# initialize sklearn objects
	rf = RandomForestClassifier(n_estimators = 200, max_depth = 3, verbose = 1, random_state = SEED)
	
	print('loading fit data ... ')
	#fit_x, fit_y = load_fit_data(train_loc)
    model_skeleton = littleBadBoy(fit_x, reader, SEED, path, rf, train_loc)
    model_skeleton.load_fit_data()
	
	# rf feature transformation
    #############################
    # How to include in object? #
    #############################
	print('fitting data ... ')
	rf.fit(fit_x, fit_y)
	fit_x = None
	fit_y = None
	
	print('writing training file with tree features ... ')
	#load_train_data(train_loc, rf)
    model_skeleton.load_train_data()
	
	print('writing test file with tree features ... ')
	#load_test_data(test_loc, rf)
    model_skeleton.load_test_data()
	
	
if __name__ == '__main__':
	main()