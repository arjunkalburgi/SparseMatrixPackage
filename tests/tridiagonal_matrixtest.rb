require 'test/unit'
require_relative '../sparsematrixpackage/tridiagonalmatrix.rb'

class tridiagonalmatrixtest < Test::Unit::TestCase
    def setup
        pass 
    end 

    def teardown
        pass
    end

    def test_fail
        assert(false, 'Assertion was false.')
    end
	
	def test_create
		tridiagonal = TriDiagonalMatrix.new([[1,2,0,0,0],
											 [3,1,2,0,0],
										 	 [0,3,1,2,0],
											 [0,0,3,1,2],
											 [0,0,0,3,1])
		# success?
		assert(true, "create was successful")
	end
	
	def test_bad_create
		tridiagonal = TriDiagonalMatrix.new([[1,2,0,0,5],
											 [0,1,2,0,0],
										 	 [0,3,0,0,0],
											 [0,0,3,1,2],
											 [5,0,0,3,1])
		# how to pass test on failure?
	end
end