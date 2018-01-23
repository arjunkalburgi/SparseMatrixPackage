# :)
require 'matrix'

# inherits from Matrix for utilization of 
class TriDiagonalMatrix < Matrix
	# let matrix handle these functions
	# delegate [:+, :**, :-, :hermitian?, :normal?, :permutation?] => :Matrix.send(:new, to_a)
	
	# all public methods
	 
	def initialize(matrix_array)
		#PRE
		ensuresquare(matrix_array) #ensure nxn		
		
		#rows = convert_to_array(matrixarray, true) # not sure if true is needed to copy object
		
		# basing size on first row
		@size = matrix_array[0].size 
		
		topDiag = []
		middleDiag = []
		bottomDiag = []
		
		# ensure there are 3 diagonals of proper sizes
		# ensure tridiagonality at assignment (reduces 
	
		for i in 0..matrix_array.size do 
			raise "Matrix not tridiagonal: rows of various sizes" unless 
					@size == row.size
			raise "Matrix not tridiagonal: matrix not square" unless 
					matrix_array[i].size == row.size
			for j in 0..matrix_array[i].size do 
				case i
					when j - 1
						topDiag << matrix_array[i][j]
					when j
						middleDiag << matrix_array[i][j]
					when j + 1
						bottomDiag << matrix_array[i][j]
					else 
						raise "Not a tridiagonal matrix" unless matrix_array[i][j] == 0
				end		
			end
		end
		
		@topDiagonal = topDiagonal
		@middleDiagonal = middle
		@bottomDiagonal = bottom
		
		#POST
		diagonal_array_sizes()
	end
	
	def /(mat)
		if mat.respond_to?("inverse")
			self * mat.inverse
		else 
			map {|x| x/mat}	
		end
	end
	
	def map
		to_enum :map
	end

	# all private methods
	
	private 
	
	def ensure_square(matrix_array) 
		
	end

	def diagonal_array_sizes()
		raise "The diagonal arrays are of impropersize" unless 
			@middle_diag.size == @top_diag.size+2 and @middle_diag.size == @bottom_diag.size+2
	end
end
