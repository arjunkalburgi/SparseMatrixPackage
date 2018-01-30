require 'test/unit'
require 'matrix'
require_relative '../sparsematrixpackage/tridiagonal_matrix.rb'

class TridiagonalMatrixTest < Test::Unit::TestCase
	def setup
		@matrix1 = TriDiagonalMatrix.rows([[1,2,0,0,0],
										  [3,1,2,0,0],
										  [0,3,1,2,0],
										  [0,0,3,1,2],
										  [0,0,0,3,1]])
		@matrix2 = TriDiagonalMatrix.rows([[5,2,0,0,0],
										  [3,1,14,0,0],
										  [0,10,7,2,0],
										  [0,0,3,3,11],
										  [0,0,0,8,9]])
	end 
	
	def test_create
		tridiagonal = TriDiagonalMatrix.rows([[1,2,0,0,0],
											 [3,1,2,0,0],
										 	 [0,3,1,2,0],
											 [0,0,3,1,2],
											 [0,0,0,3,1]])
		# success?
		assert(true, "create was successful")
	end
	
	def test_bad_create
		assert_throws("Matrix not tridiagonal: does not obey upper and lower Hessenberg matrix properties") {
		tridiagonal = TriDiagonalMatrix.rows([[1,2,0,0,5],
											 [0,1,2,0,0],
											 [0,3,0,0,0],
											 [0,0,3,1,2],
											 [5,0,0,3,1]])
		}
	end
	
	def test_add
		addedMatrix = TriDiagonalMatrix.rows([[6,4,0,0,0], 
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
		matrix3 = TriDiagonalMatrix.rows([[12, 15], [1, 4], [9, 0]])
		assert_throws("Cannot perform operation, deminsions do not match."){
			@matrix1+matrix3
		}
	end
	
	def test_subtract
		subtractedMatrix = TriDiagonalMatrix.rows([[-4,0,0,0,0], 
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
		matrix3 = TriDiagonalMatrix.rows([[12, 15], [1, 4]])
		assert_throws("Cannot perform operation, deminsions do not match."){
			@matrix1-matrix3
		}
	end
	
	
	def test_multiply
		multipliedMatrix = Matrix.rows([[11,4,28,0,0], 
									   [18,27,28,4,0],
									   [9,13,55,8,22],
									   [0,30,24,25,29],
									   [0,0,9,17,42]])
		assert_equal(multipliedMatrix, @matrix1*@matrix2)
		multipliedMatrix2 = Matrix.rows([[2,4,0,0,0],
										[6,2,4,0,0],
										[0,6,2,4,0],
										[0,0,6,2,4],
										[0,0,0,6,2]])
		assert_equal(multipliedMatrix2, @matrix1*2)
	end
	
	
	def test_divide
		dividedMatrix = Matrix.rows([[10945/43181,-3848/43181,6832/43181,2016/43181,-2464/43181], 
									 [21960/43181,6581/43181,-732/43181,-216/43181,264/43181],
									 [879/43181,-1465/43181,12925/43181,-8928/43181,10912/43181],
									 [-4860/43181,8100/43181,162/43181,5003/43181,3481/43181],
									 [-1710/43181,2850/43181,57/43181,-13433/43181,21216/43181]])
		assert_equal(dividedMatrix, @matrix1/@matrix2)
		dividedMatrix2 = TriDiagonalMatrix.rows(TriDiagonalMatrix.rows([[0.5,1,0,0,0],
																	    [1.5,0.5,1,0,0],
																	    [0,1.5,0.5,1,0],
																	    [0,0,1.5,0.5,1],
																	    [0,0,0,1.5,0.5]]))
		assert_equal(dividedMatrix2, @matrix1/2)
	end
	
	def test_equals
		assert(@matrix1==@matrix1)
		assert(!@matrix1==@matrix2)
		matrix3 = TriDiagonalMatrix.rows([[1,2,0,0,0],
										 [3,1,2,0,0],
										 [0,3,1,2,0],
										 [0,0,3,1,2],
										 [0,0,0,3,1]])
		assert(@matrix1==matrix3)
	end
	
	def test_determinant
		determinant = 85 #calculated by hand
		assert_equal(determinant, @matrix1.determinant)
	end
	
	def test_inverse
		inverseMatrix = Matrix.rows([[19/85,22/85,-4/17,-8/85,16/85],
									 [33/85,-11/85,2/17,4/85,-8/85],
									 [-9/17,3/17,5/17,2/17,-4/17],
									 [-27/85,9/85,3/17,-11/85,22/85],
									 [81/85,-27/85,-9/17,33/85,19/85]]) #calculated by hand
		assert_equal(@matrix1.getInverse(), inverseMatrix)
	end
	
	
	def test_transpose
		matrix1_transpose = TriDiagonalMatrix.rows([[1,3,0,0,0],
												    [2,1,3,0,0],
												    [0,2,1,3,0],
												    [0,0,2,1,3],
												    [0,0,0,2,1]])
		assert_equal(@matrix1.getTranspose(), matrix1_transpose)
	end
end
