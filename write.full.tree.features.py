import csv
import pandas as pd
import sklearn as sk
import numpy as np

from sklearn.ensemble import RandomForestClassifier

class littleBadBoy(object):
    """ 
    This here is a jabroni sandwhich
    """
    
    def __init__(self, fit_x, SEED, path, rf, data):
        self.fit_x = fit_x
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
        #self.
        pass
        
    def load_train_data(self):
        """
        Model fit skeleton: load and prepare training data
        """
        #self.
        pass
        
    def load_test_data(self):
        """
        Model fit skeleton: load and prepare testing data
        """
        #self.
        pass
        
    def vw_ready(self):
        """
        Adds | to first col of data - prepare text files for VW
        """
        pass
        
    def __str__(self):
        """ 
        Print to screen variables
        """
        return "fit_x: %s\n seed: %s \n" % (self.fit_x, self.SEED)
        
	
def main():
    # Some opening bullshit lol
    SEED = 80085
    train_loc = 'train.day.hour.csv'
    test_loc = 'test.day.hour.csv'
    
    fit_x = pd.read_csv(path, dtype = str, nrows = 6000000, low_memory = False)
    
	# initialize sklearn objects
	rf = RandomForestClassifier(n_estimators = 200, max_depth = 3, verbose = 1, random_state = SEED)
	
	print('loading fit data ... ')
	#fit_x, fit_y = load_fit_data(train_loc)
    
    model_object = littleBadBoy(fit_x, SEED, path, rf, train_loc)
	
	# rf feature transformation
	print('fitting data ... ')
	rf.fit(fit_x, fit_y)
	fit_x = None
	fit_y = None
	
	print('writing training file with tree features ... ')
	#load_train_data(train_loc, rf)
	
	print('writing test file with tree features ... ')
	#load_test_data(test_loc, rf)
	
	
if __name__ == '__main__':
	main()