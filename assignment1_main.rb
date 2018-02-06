# Project 1
# Main file 

# Functionality of the sparse matrix package

# Group: Winter2018_Group1
#     Bianca Angotti 
#     Andrew McKernan
#     Arjun Kalburgi

require_relative './sparsematrixpackage/matrixfactory'
require_relative './sparsematrixpackage/sparse_matrix'
require_relative './sparsematrixpackage/tridiagonal_matrix'

# MatrixFactory builds Sparse and Tridiagonal matrices
sparseMatrix = MatrixFactory.create(SparseMatrix, [[1, 0, 0], 
                                                   [0, 4, 0],
                                                   [0, 1, 0]])
triDiagonal = MatrixFactory.create(TriDiagonalMatrix, [[1, 0, 0],
                                                       [0, 1, 0],
                                                       [0, 0, 1]])



# Testing
require 'test/unit'
require_relative './tests/sparse_matrixtest'
require_relative './tests/tridiagonal_matrixtest'



# Math Operations 
triDiagonal + sparseMatrix

sparseMatrix - triDiagonal

sparseMatrix * 2

triDiagonal * sparse

sparseMatrix / 2

triDiagonal.determinant

triDiagonal.inverse

sparseMatrix.transpose



# Properties
triDiagonal.diagonal?

sparseMatrix.zero?

sparseMatrix.square?

triDiagonal.real?

sparseMatrix.imaginary?

triDiagonal.orthoganal?



# Enumerate
sparseMatrix.each(:nonzero) { |x| x }

triDiagonal.each(:tridiagonal) { |x| x }