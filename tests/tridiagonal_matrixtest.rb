require 'test/unit'
require_relative '../TriDiagonalMatrixpackage/tridiagonal_matrix.rb'

class TridiagonalMatrixTest < Test::Unit::TestCase
    def setup
		@matrix1 = TriDiagonalMatrix.new([[1,2,0,0,0],
										  [3,1,2,0,0],
										  [0,3,1,2,0],
										  [0,0,3,1,2],
										  [0,0,0,3,1]])
		@matrix2 = TriDiagonalMatrix.new([[5,2,0,0,0],
										  [3,1,14,0,0],
										  [0,10,7,2,0],
										  [0,0,3,3,11],
										  [0,0,0,8,9]])
    end 
	
	def test_create
		tridiagonal = TriDiagonalMatrix.new([[1,2,0,0,0],
											 [3,1,2,0,0],
										 	 [0,3,1,2,0],
											 [0,0,3,1,2],
											 [0,0,0,3,1]])
		# success?
		assert(true, "create was successful")
	end
	
	def test_bad_create
		assert_throws("This matrix is not tridiagonal") {
		tridiagonal = TriDiagonalMatrix.new([[1,2,0,0,5],
											 [0,1,2,0,0],
										 	 [0,3,0,0,0],
											 [0,0,3,1,2],
											 [5,0,0,3,1]])
		}
	end
	
	def test_add
		addedMatrix = TriDiagonalMatrix.new([[6,4,0,0,0], 
										[6,2,16,0,0],
										[0,6,2,4,0],
										[0,0,6,4,13],
										[0,0,0,11,10]])
		assert_equal(addedMatrix, @matrix1+@matrix2)
	end
	
	def test_invalid_add
		assert_throws("Cannot perform operation, deminsions do not match."){
			@matrix1+5
		}
		matrix3 = SparseMatrix.new([[12, 15], [1, 4], [9, 0]])
		assert_throws("Cannot perform operation, deminsions do not match."){
			@matrix1+matrix3
		}
	end
	
	def test_subtract
		subtractedMatrix = TriDiagonalMatrix.new([[-4,0,0,0,0], 
												  [0,0,-12,0,0],
												  [0,-7,-6,0,0],
												  [0,0,0,-2,-9],
												  [0,0,0,-5,-8]])
		assert_equal(subtractedMatrix, @matrix1-@matrix2)
	end
	
	def test_invalid_subtract
		assert_throws("Cannot perform operation, deminsions do not match."){
			@matrix1-5
		}
		matrix3 = SparseMatrix.new([[12, 15], [1, 4], [9, 0]])
		assert_throws("Cannot perform operation, deminsions do not match."){
			@matrix1-matrix3
		}
	end
	
	def test_multiply
		# this is not a triagonal matrix, what to do here?
		multipliedMatrix = TriDiagonalMatrix.new([[11,4,28,0,0], 
												  [18,27,28,4,0],
												  [9,13,55,8,22],
												  [0,30,24,25,29],
												  [0,0,9,17,42]])
		assert_equal(multipliedMatrix, @matrix1*@matrix2)
		multipliedMatrix2 = TriDiagonalMatrix.new([[2,4,0,0,0],
												   [6,2,4,0,0],
												   [0,6,2,4,0],
												   [0,0,6,2,4],
												   [0,0,0,6,2]])
		assert_equal(multipliedMatrix2, @matrix1*2)
	end
	
	def test_divide
		dividedMatrix = TriDiagonalMatrix.new([[2, 2], [0, 0]])
		assert_equal(dividedMatrix, @matrix1/@matrix2)
		dividedMatrix2 = TriDiagonalMatrix.new([[4, 5], [0, 0]])
		assert_equal(dividedMatrix2, matrix1/2)
	end
	
	def test_equals
		assert(@matrix1==@matrix1)
		assert(!@matrix1==@matrix2)
		matrix3 = TriDiagonalMatrix.new([[8, 10], [0, 0]])
		assert(@matrix1==matrix3)
	end
	
	def test_determinant
		determinant = 85 #calculated by hand
		assert_equal(determinant, @matrix1.getDeterminant)
	end
	
	def test_inverse
		@matrix1 = TriDiagonalMatrix.new([[4,7],
									[2,6]])
		inverseMatrix = [[0.6,-0.7],
						[-0.2,0.4]] #calculated by hand
		assert_equal(@matrix1, inverseMatrix)
	end
	
	
	def test_transpose
		matrix1_transpose = [[8,0],
							[10,0]]
		assert_equal(@matrix1.getTranspose(), matrix1_transpose)
	end
end
