require 'test/unit'
require_relative '../sparsematrixpackage/tridiagonal_matrix.rb'

class TridiagonalMatrixTest < Test::Unit::TestCase
    #def setup
    #    pass 
    #end 

    #def teardown
    #    pass
    #end

    #def test_fail
    #    assert(false, 'Assertion was false.')
    #end
	
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
end
