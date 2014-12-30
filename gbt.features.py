import pandas as pd
import numpy as np

from sklearn.ensemble import GradientBoostingClassifier

train_loc = 'train.day.hour.csv'
test_loc = 'test.day.hour.csv'

# get leaf indices from GBT ensemble
def get_leaf_indices(ensemble, x):
    x = x.astype(np.float32)
    trees = ensemble.estimators_
    n_trees = trees.shape[0]
    indices = []

    for i in range(n_trees):
        tree = trees[i][0].tree_
        indices.append(tree.apply(x))

    indices = np.column_stack(indices)
    return indices

# get y values into VW format
def vw_ready(data):
    data[data == 0] = -1
    data = (data.astype(str) + ' |C').as_matrix()
    
    return data

# load and prepare model fit data
def load_fit_data(path):
    fit_x = pd.read_csv(path, dtype = str)
    fit_y = fit_x['click'].astype(int).values
    fit_x = fit_x.drop('click', 1)
    fit_x = fit_x.drop('id', 1)
    for colname in list(fit_x.columns.values):
        fit_x[colname] = pd.Categorical.from_array(fit_x[colname]).codes
    
    fit_x = fit_x.values
    
    return fit_x, fit_y
    
# load, fit, transform and write training data to VW format
def load_train_data(path, gbt):
    reader = pd.read_csv(path, dtype = str, chunksize = 10000)
    for chunk in reader:
        click = chunk['click'].astype(int)
        chunk = chunk.drop('click', 1)
        chunk = chunk.drop('id', 1)
        
        # create array of original data
        orig = []
        for colname in list(chunk.columns.values):
            orig.append(colname + chunk[colname])
            chunk[colname] = pd.Categorical.from_array(chunk[colname]).codes
            
        chunk = chunk.values
        orig = np.column_stack(orig)
        
        # create array of tree features
        train_tree = get_leaf_indices(gbt, chunk).astype(str)
        for row in range(0, chunk.shape[0]):
            for column in range(0, 30, 1):
                train_tree[row, column] = ('T' + str(column) + str(train_tree[row, column]))

        # get clicks into VW format and create output array  to write to file
        click = vw_ready(click)
        out = np.column_stack((click, orig, train_tree))

        # write file
        file_handle = file('train.tree.txt', 'a')
        np.savetxt(file_handle, out, delimiter = ' ', fmt = '%s')
        file_handle.close()
        
# load, fit, transform and write testing data to VW format
def load_test_data(path, gbt):
    reader = pd.read_csv(path, dtype = str, chunksize = 10000)
    for chunk in reader:
        id = chunk['id']
        chunk = chunk.drop('id', 1)
        
        # create array of original data
        orig = []
        for colname in list(chunk.columns.values):
            orig.append(colname + chunk[colname])
            chunk[colname] = pd.Categorical.from_array(chunk[colname]).codes

        chunk = chunk.values
        orig = np.column_stack(orig)

        # create array of tree features
        test_tree = get_leaf_indices(gbt, chunk).astype(str)
        for row in range(0, chunk.shape[0]):
            for column in range(0, 30, 1):
                test_tree[row, column] = ('T' + str(column) + str(test_tree[row, column]))

        # get id into VW formate and crate output array to write to file
        id = (id.astype(str) + ' |C').as_matrix()
        out = np.column_stack((id, orig, test_tree))
        
        # write file
        file_handle = file('test.tree.txt', 'a')
        np.savetxt(file_handle, out, delimiter = ' ', fmt = '%s')
        file_handle.close()

# do the process
def main():
    gbt = GradientBoostingClassifier(n_estimators = 30, max_depth = 7, verbose = 1)
    
    print('loading fit data ... ')
    fit_x, fit_y = load_fit_data(train_loc)
    
    print('fitting gbt ... ')
    gbt.fit(fit_x, fit_y)
    fit_x = None
    fit_y = None
    
    print('writing training file for VW with gbt features ... ')
    load_train_data(train_loc, gbt)
    
    print('writing test file for VW with gbt features ... ')
    load_test_data(test_loc, gbt)
    
if __name__ == '__main__':
    main()
