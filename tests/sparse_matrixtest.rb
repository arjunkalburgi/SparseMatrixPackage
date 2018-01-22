require 'test/unit'
require_relative '../sparsematrixpackage/sparse_matrix.rb'

class sparsematrixtest < Test::Unit::TestCase
    def setup
        pass 
    end 

    def teardown
        pass
    end

    def test_fail
        assert(false, 'Assertion was false.')
    end
	
	def test_add
		matrix1 = SparseMatrix.new([0, 0, 1, 0])
		matrix2 = SparseMatrix.new([1, 0, 0, 0])
		addedMatrix = SparseMatrix.new([1, 0, 1, 0])
		assert_equal(addedMatrix, matrix1+matrix2)
	end
	
	def test_subtract
		matrix1 = SparseMatrix.new([1, 1, 1, 4])
		matrix2 = SparseMatrix.new([1, 1, 0, 4])
		subtractedMatrix = SparseMatrix.new([0, 0, 1, 0])
		assert_equal(subtractedMatrix, matrix1-matrix2)
	end
	
	def test_multiply
		matrix1 = SparseMatrix.new([2, 3, 1, 4])
		matrix2 = SparseMatrix.new([4, 5, 0, 4])
		multipliedMatrix = SparseMatrix.new([8, 15, 0, 16])
		assert_equal(multipliedMatrix, matrix1*matrix2)
	end
	
	def test_divide
		matrix1 = SparseMatrix.new([8, 10, 0, 0])
		matrix2 = SparseMatrix.new([4, 5, 1, 4])
		dividedMatrix = SparseMatrix.new([2, 2, 0, 0])
		assert_equal(dividedMatrix, matrix1/matrix2)
	end
	
	def test_exponent
		# how does this work though
	end
	
	def test_determinant
	
	end
	
	def test_inverse
	
	end
	
	def test_transpose
	
	end
	
end