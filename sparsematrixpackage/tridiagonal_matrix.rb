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
		
		@num_rows = matrix_array.size 
		# basing column size on first row
		@num_columns = matrix_array[0].size 
		
		top_diag = []
		middle_diag = []
		bottom_diag = []
		
		# ensure there are 3 diagonals of proper sizes
		# ensure tridiagonality at assignment (reduces 
	
		for i in 0..matrix_array.size do 
			raise "Matrix not tridiagonal: rows of various sizes" unless 
					@num_columns == matrix_array[i].size
			raise "Matrix not tridiagonal: matrix not square" unless 
					@num_rows == matrix_array[i].size
			for j in 0..matrix_array[i].size do 
				case i
					when j - 1
						top_diag << matrix_array[i][j]
					when j
						middle_diag << matrix_array[i][j]
					when j + 1
						bottom_diag << matrix_array[i][j]
					else 
						raise "Matrix not tridiagonal: does not obey upper and lower Hessenberg matrix properties" unless matrix_array[i][j] == 0
				end		
			end
		end
		
		@top_diagonal = top_diag
		@middle_diagonal = middle_diag
		@bottom_diagonal = bottom_diag
		
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
			@middle_diagonal.size == @top_diagonal.size+2 and @middle_diagonal.size == @bottom_diagonal.size+2
	end
end
