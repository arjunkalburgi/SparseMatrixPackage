require 'test/unit'
require_relative '../sparsematrixpackage/sparse_matrix.rb'

class SparseMatrixTest < Test::Unit::TestCase
    def setup
		@matrix1 = SparseMatrix.new([[8, 10],
									[0, 0]])
		@matrix2 = SparseMatrix.new([[4, 5], 
									[1, 4]])
    end 

    #def teardown
    #    pass
    #end

    #def test_fail
    #    assert(false, 'Assertion was false.')
    #end
	
	def test_add
		addedMatrix = SparseMatrix.new([[12, 15], [1, 4]])
		assert_equal(addedMatrix, @matrix1+@matrix2)
	end
	
	def test_invalid_add
		assert_raise("Cannot perform operation, deminsions do not match.") do
			@matrix1+5
		end
		matrix3 = SparseMatrix.new([[12, 15], [1, 4], [9, 0]])
		assert_raise("Cannot perform operation, deminsions do not match.") do
			@matrix1+matrix3
		end
	end
	
	def test_subtract
		subtractedMatrix = SparseMatrix.new([[4, 5], [-1, -4]])
		assert_equal(subtractedMatrix, @matrix1-@matrix2)
	end
	
	def test_invalid_subtract
		assert_raise("Cannot perform operation, deminsions do not match.") do
			@matrix1-5
		end
		matrix3 = SparseMatrix.new([[12, 15], [1, 4], [9, 0]])
		assert_raise("Cannot perform operation, deminsions do not match.") do
			@matrix1-matrix3
		end
	end
	
	def test_multiply
		multipliedMatrix = SparseMatrix.new([[42, 80], [0, 0]])
		assert_equal(multipliedMatrix, @matrix1*@matrix2)
		multipliedMatrix2 = SparseMatrix.new([[16, 20], [0, 0]])
		assert_equal(multipliedMatrix2, @matrix1*2)
	end
	
	def test_divide
		dividedMatrix = SparseMatrix.new([[2, 0], [0, 0]])
		assert_equal(dividedMatrix, @matrix1/@matrix2)
		dividedMatrix2 = SparseMatrix.new([[4, 5], [0, 0]])
		assert_equal(dividedMatrix2, @matrix1/2)
	end
	
	def test_equals
		assert(@matrix1==@matrix1)
		assert(@matrix1!=@matrix2)
		matrix3 = SparseMatrix.new([[8, 10], [0, 0]])
		assert(@matrix1==matrix3)
	end
	
	def test_determinant
		@matrix1 = SparseMatrix.new([[3, 8],
									[4, 6]])
		determinant = -14 #calculated by hand
		assert_equal(determinant, @matrix1.determinant)
	end
	
	def test_inverse
		@matrix1 = SparseMatrix.new([[4,7],
									[2,6]])
		inverseMatrix = [[0.6,-0.7],
						[-0.2,0.4]] #calculated by hand
		assert_equal(@matrix1.inverse, SparseMatrix.new(inverseMatrix))
	end

	def test_inverse2
		matrixToInvert = SparseMatrix.new([[-1,-1],
										   [0,-1]])
		inverseMatrix = Matrix.rows([[-1, 1],
									 [0, -1]])
		assert_equal(matrixToInvert.inverse, SparseMatrix.new(inverseMatrix))
	end

	def test_transpose
		matrix1_transpose = [[8,0],
							[10,0]]
		assert_equal(@matrix1.transpose, SparseMatrix.new(matrix1_transpose))
	end
	
	def test_get
		assert_equal(@matrix1.get(0,0), 8)
	end
	
	# def test_invalid_get
	
	# end
	
	def test_set
		@matrix1.set(0,0,19)
		assert_equal(@matrix1.get(0,0), 19)
	end
	
	# def test_to_s
	
	# end
	
	def test_to_m
		assert_equal(@matrix1.to_m, Matrix.rows([[8, 10],
												 [0, 0]]))
	end
	
	def test_to_a
		assert_equal(@matrix1.to_a, [[8, 10],[0, 0]])
	end
	
	# def test_invalid_set
	
	# end
	
	# def test_dimensions
	
	# end
	
	def test_map
		
	end
	
	def test_row
		assert_equal(@matrix1.row(0),[8,10])
	end
	
	# def test_invalid_row
	
	# end
	
	def test_column
		assert_equal(@matrix1.column(0),[8,0])
	end
	
	# def test_invalid_column
	
	# end
	
	#def test_each
	
	#end
	
end
