# Project 1
# Main file 

# Functionality of the sparse matrix package

# Group: Winter2018_Group1
#     Bianca Angotti 
#     Andrew McKernan
#     Arjun Kalburgi

require_relative 'sparsematrixpackage'

# MatrixFactory builds Sparse and Tridiagonal matrices
sparseMatrix = MatrixFactory.create(SparseMatrix, [[1, 0, 0], 
                                                   [0, 4, 0],
                                                   [0, 1, 0]])
triDiagonal = MatrixFactory.create(TridiagonalMatrix, [[1, 0, 0],
                                                       [0, 1, 0],
                                                       [0, 0, 1]])



# Testing
require 'test/unit'
require_relative './tests/sparse_matrixtest'
require_relative './tests/tridiagonal_matrixtest'



# Math Operations 
triDiagonal + sparse

sparse - triDiagonal

sparse * 2

triDiagonal * sparse

sparse / 2

triDiagonal.determinant

triDiagonal.inverse

sparse.transpose



# Properties
triDiagonal.diagonal?

sparse.zero?

sparse.square?

triDiagonal.real?

sparse.imaginary?

triDiagonal.orthoganal?



# Enumerate
sparse.each(:nonzero) { |x| x }

triDiagonal.each(:tridiagonal) { |x| x }