# :)
require 'matrix'

class TriagonalMatrix
	
	def initialize(matrixarray)
		#pre 
		is_array(matrixarray)
		ensuresquare(matrixarray)
		ensuretridiagonality(matrixarray)

		@top_diag = top
		@middle_diag = middle
		@bottom_diag = bottom
		
	end

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
