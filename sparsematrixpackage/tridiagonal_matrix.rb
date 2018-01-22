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
		
		topDiag = []
		middleDiag = []
		bottomDiag = []
		
		rows.each_with_index do |row, i|
			row.each_with_index do |val, j|
				case i
					when j - 1
						topDiag << val
					when j
						middleDiag << val
					when j + 1
						bottomDiag << val
					else 
						raise "Not a tridiagonal matrix" unless val == 0
				end		
			end
		end
		
		@topDiagonal = topDiagonal
		@middleDiagonal = middle
		@bottomDiagonal = bottom
		
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
