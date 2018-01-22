# Project 1
# Main file 

# See test files for execution instructions 

# Group: Winter2018_Group1
#     Bianca Angotti 
#     Andrew McKernan
#     Arjun Kalburgi

require_relative 'sparsematrixpackage'

# All functionality 

# Plan to utilize factory and call different matricies
sparseMatrix = MatrixFactory.create(SparseMatrix, [[1, 0, 0], [0, 4, 0], [0, 1, 0]])
triDiagonal = MatrixFactory.create(TridiagonalMatrix, [[1, 0, 0], [0, 1, 0], [0, 0, 1]])

# test operations
sparseMatrix - triDiagonal
# add, divide, det, etc
