
require 'matrix'

# inherits from Matrix for utilization of 
class TriDiagonalMatrix < Matrix
	# let matrix handle these functions
	# delegate [:+, :**, :-, :hermitian?, :normal?, :permutation?] => :Matrix.send(:new, to_a)
	
	# all public methods
	 
	def initialize(matrix_array)
		#PRE
		
		#rows = convert_to_array(matrixarray, true) # not sure if true is needed to copy object
		
		# basing column size on first row
		@num_columns = matrix_array[0].size 
		@num_rows = matrix_array.size 
		
		top_diag = []
		middle_diag = []
		bottom_diag = []
		
		# ensure there are 3 diagonals of proper sizes
		# ensure tridiagonality at assignment (reduces 
	
		for i in 0..matrix_array.size do 
			# ensures that the input is correct
			raise "Matrix not tridiagonal: rows of various sizes" unless 
					@num_columns == matrix_array[i].size
			# ensures that matrix is nxn
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
		begin 
			diagonal_array_sizes()
		end
	end
	
	def get_upper_diagonal
		@upper_diagonal
	end

	def get_middle_diagonal
		@middle_diagonal
	end

	def get_lower_diagonal
		@lower_diagonal
	end
	
	# overwrite methods by matrix
	def ==(other_object) 
		return false unless TriDiagonalMatrix === other_object && 
			other_object.respond_to?(:get_upper_diagonal) && 
			other_object.respond_to?(:get_middle_diagonal) && 
			other_object.respond_to?(:get_lower_diagonal) && 
			@upper_diagonal.eql?(other_object.get_upper_diagonal) &&
			@middle_diagonal.eql?(other_object.get_middle_diagonal) &&
			@lower_diagonal.eql?(other_object.get_lower_diagonal)
	end
	
	def eql?(other_object)
		return false unless TriDiagonalMatrix === other_object && 
			other_object.respond_to?(:get_upper_diagonal) && 
			other_object.respond_to?(:get_middle_diagonal) && 
			other_object.respond_to?(:get_lower_diagonal) && 
			@upper_diagonal.eql?(other_object.get_upper_diagonal) &&
			@middle_diagonal.eql?(other_object.get_middle_diagonal) &&
			@lower_diagonal.eql?(other_object.get_lower_diagonal)
	end
	
	def +(other_matrix)
		#Pre 
		# matrix is tridiagonal
		begin 
			raise "Other object is not tridiagonal" unless TriDiagonalMatrix === other_matrix
		end 
		# same dimensions
		begin 
			raise "Matricies do not have the same dimentions" unless @middle_diagonal.size == other_matrix.get_middle_diagonal.size
		end

		upper = [@upper_diagonal, other_matrix.get_upper_diagonal].transpose.map {|x| x.reduce(:+)}
		middle = [@middle_diagonal, other_matrix.get_middle_diagonal].transpose.map {|x| x.reduce(:+)}
		lower = [@lower_diagonal, other_matrix.get_lower_diagonal].transpose.map {|x| x.reduce(:+)}
		
		#Post
		# this sparse matrix has had the contents of give matrix added to it
		#new Tridiagonal???
	end
	
	def -(other_matrix)
		#Pre 
		# matrix is tridiagonal
		begin 
			raise "Other object is not tridiagonal" unless TriDiagonalMatrix === other_matrix
		end 
		# same dimensions
		begin 
			raise "Matricies do not have the same dimentions" 
				unless @middle_diagonal.size == other_matrix.get_middle_diagonal.size
		end
		
		upper = [@upper_diagonal, other_matrix.get_upper_diagonal].transpose.map {|x| x.reduce(:-)}
		middle = [@middle_diagonal, other_matrix.get_middle_diagonal].transpose.map {|x| x.reduce(:-)}
		lower = [@lower_diagonal, other_matrix.get_lower_diagonal].transpose.map {|x| x.reduce(:-)}
		
		#Post
		# this sparse matrix has had the contents of given matrix subtracted from it
	end
	
	def *(matrix)
		#Pre 
		
		#Post
		# this sparse matrix has been multiplied by given matrix 
	end
	
	def /(matrix)
		#Pre 
		
		#Post
		# this sparse matrix has been divided by given matrix
	end
	
	def /(mat)
		if mat.respond_to?("inverse")
			self * mat.inverse
		else 
			map {|x| x/mat}	
		end
	end
		
	def determinant
# 		@middle_diagonal[1..-1].zip(@upper_diagonal, @lower_diagonal).reduce([1, @middle_diagonal[0]]) do |c, x|
# 			c << x[0] * c.last - x[1] * x[2] * c[-2]
# 		end.last
	end
		
# 	def transpose!
# 		@upper_diagonal, @lower_diagonal = @lower_diagonal, @upper_diagonal
# 		self
# 	end

# 	def transpose
# 		self.class.send(:new, @lower_diagonal, @middle_diagonal, @upper_diagonal)
# 	end
	
	def square?
		true
	end

# 	def diagonal?
# 		@upper_diagonal.all? { |x| x == 0 } && @lower_diagonal.all? { |x| x == 0 }
# 	end

# 	def toeplitz?
# 		@upper_diagonal.reduce(true) { |a, e| a && e == @upper_diagonal[0] }
# 	end

	def upper_triangular?
		false
	end

	def orthogonal?
		transpose == inverse
	end

	def symmetric?
		self == transpose
	end

	# all private methods
	
	private 

	def diagonal_array_sizes()
		raise "The diagonal arrays are of improper size" unless 
			@middle_diagonal.size == @top_diagonal.size+2 and @middle_diagonal.size == @bottom_diagonal.size+2
	end
end
