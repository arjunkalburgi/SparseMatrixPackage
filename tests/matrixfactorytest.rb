require 'test/unit'
require 'matrix'
require_relative '../sparsematrixpackage/matrixfactory.rb'

class MatrixFactoryTest < Test::Unit::TestCase
    def setup
        #pass 
    end 
    
    def test_create_by_arrays
		MatrixFactory.create(SparseMatrix,[[0,0,0],
										   [0,1,0],
										   [0,0,0]])
		MatrixFactory.create(TriDiagonalMatrix,[[1,0,0],
												[0,1,0],
												[0,0,1]])
		assert(true,"pass")
    end
    
    def test_bad_create
		assert_raise do
			MatrixFactory.create(SparseMatrix, 123)
		end
		assert_raise do
			MatrixFactory.create(TriDiagonalMatrix, "lol")
		end
    end
    
    def test_create_by_dimension
		MatrixFactory.create(SparseMatrix, 2, 3)
		MatrixFactory.create(TriDiagonalMatrix, 3, 3)
    end
    
    def test_bad_create_by_dimension
		assert_raise do
			MatrixFactory.create(SparseMatrix, -2, -3)
		end
		assert_raise do
			MatrixFactory.create(TriDiagonalMatrix, -3, -3)
		end
    end
    
    def test_create_by_matrix
		MatrixFactory.create(TriDiagonalMatrix, Matrix.rows([[0,0,0],
															[0,1,0],
															[0,0,0]]))
															
		MatrixFactory.create(SparseMatrix, Matrix.rows([[0,0,0],
															[0,1,0],
															[0,0,0]]))
    end
    
    def test_create_tridiagonal_by_diagonals
		MatrixFactory.create(TriDiagonalMatrix, [1,1,1],[2,2,2,2],[3,3,3])
    end
    
    def test_invalid_create_tridiagonal_by_diagonals
		assert_raise do
			MatrixFactory.create(TriDiagonalMatrix, [1,1,1],[2,2,2],[3,3,3]) #middle diagonal is too short
		end
    end
    
    def test_create_sparse_by_hash
		MatrixFactory.create(SparseMatrix, {{row: 4, column: 3}=> 5})
		MatrixFactory.create(SparseMatrix, {{row: 4, column: 3}=> 5},7,7) #7x7 matrix where [4][3] = 5
    end
    
    def test_invalid_create_sparse_by_hash
		assert_raise do
			MatrixFactory.create(SparseMatrix, {{wrongName: 4, column: 3}=> 5})
		end
		assert_raise do
			MatrixFactory.create(SparseMatrix, {{row: 4, column: 3}=> 5},7,-7)
		end
		assert_raise do
			MatrixFactory.create(SparseMatrix, {{row: 4}=> 5})
		end
    end
end
