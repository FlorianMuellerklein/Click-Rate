import pandas as pd
import numpy as np

from sklearn.ensemble import GradientBoostingClassifier

train_loc = 'train.day.hour.csv'
test_loc = 'test.day.hour.csv'
TREES = 2
NODES = 5

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
def load_fit_data(path, gbt):
    fit_x = pd.read_csv(path, dtype = str)
    fit_y = fit_x['click'].astype(int).values
    fit_x = fit_x.drop('click', 1)
    fit_x = fit_x.drop('id', 1)
    for colname in list(fit_x.columns.values):
        fit_x[colname] = pd.Categorical.from_array(fit_x[colname]).codes
    
    fit_x = fit_x.values
    
    gbt.fit(fit_x, fit_y)
    
    return gbt
    
# load, fit, transform and write data to VW format
def load_data(path, gbt, train):
    reader = pd.read_csv(path, dtype = str, chunksize = 10000)
    for chunk in reader:
        if train == True:
            y = chunk['click'].astype(int)
            chunk = chunk.drop('click', 1)
            chunk = chunk.drop('id', 1)
            y = vw_ready(y)
        else:
            y = chunk['id']
            chunk = chunk.drop('id', 1)
            y = (y.astype(str) + ' |C').as_matrix()
            
        # create array of original data
        orig = []
        for colname in list(chunk.columns.values):
            orig.append(colname + chunk[colname])
            chunk[colname] = pd.Categorical.from_array(chunk[colname]).codes
            
        chunk = chunk.values
        orig = np.column_stack(orig)
        
        # create array of tree features
        x_tree = get_leaf_indices(gbt, chunk).astype(str)
        for row in range(0, chunk.shape[0]):
            for column in range(0, TREES, 1):
                x_tree[row, column] = ('T' + str(column) + str(x_tree[row, column]))

        # get clicks into VW format and create output array  to write to file
        out = np.column_stack((y, orig, x_tree))

        # write file
        if train == True:
            file_handle = file('train.tree.txt', 'a')
            np.savetxt(file_handle, out, delimiter = ' ', fmt = '%s')
            file_handle.close()
        else:
            file_handle = file('test.tree.txt', 'a')
            np.savetxt(file_handle, out, delimiter = ' ', fmt = '%s')
            file_handle.close()

# do the process
def main():
    gbt = GradientBoostingClassifier(n_estimators = TREES, max_depth = NODES, verbose = 1)
    
    print('loading data and fitting gbt ... ')
    gbt = load_fit_data(train_loc, gbt)
    
    print('writing training file for VW with gbt features ... ')
    load_data(train_loc, gbt, train = True)
    
    print('writing test file for VW with gbt features ... ')
    load_data(test_loc, gbt, train = False)
    
if __name__ == '__main__':
    main()
