# :)
require 'matrix'

# inherits from Matrix for utilization of 
class TriDiagonalMatrix < Matrix
	
	# let matrix handle these functions
	# delegate [:+, :**, :-, :hermitian?, :normal?, :permutation?] => :Matrix.send(:new, to_a)
	
	# all public methods...
	 
	def initialize(matrixarray)
		#PRE
		is_array(matrixarray)
		ensuresquare(matrixarray) #ensure nxn
		ensuretridiagonality(matrixarray) #ensure there are 3 diagonals of proper sizes
		
		rows = convert_to_array(matrixarray, true) # not sure if true is needed to copy object
		
		@size = (rows[0] || []).size 
		
		@top_diag = top
		@middle_diag = middle
		@bottom_diag = bottom
		
		#POST
	end

	
	# all private methods...
	
	private 
	
	def ensuretridiagonality(matrixarray)
		#pre 
		is_array(matrixarray)
		
		n = matrixarray.size
		for index_i in 0..n do
			for index_j in 0..n do
				if index_i == index_j or index_i == index_j+1 or index_i == index_j-1
					raise "This matrix is not tridiagonal" unless matrixarray[index_i][index_j] == 0
				end
			end
		end
	end 
end
