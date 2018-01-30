
require 'matrix'

# inherits from Matrix for utilization of 
class TriDiagonalMatrix < Matrix
	# let matrix handle these functions
	delegate [:**, :hermitian?, :normal?, :permutation?] => :Matrix.send(:new, to_a)
	
	include Enumerable

	attr_reader :upper_diagonal, :middle_diagonal, :lower_diagonal

	def self.rows(rows, copy = true)
		
		rows = convert_to_array(rows, true) 
		rows.map! { |row| convert_to_array(row, copy) }

		# basing column size on first row
		@num_columns = (rows[0] || []).size
		@num_rows = rows.size 
		
		upper_diag = []
		middle_diag = []
		lower_diag = []
		
		#PRE
		#raise methods for preconditions included within initialization
		#to minimize loops ran
		#ensures there are 3 diagonals of proper sizes
	
		for i in 0..rows.size do 
			# ensures that the input is correct
			raise "Matrix not tridiagonal: rows of various sizes" unless 
					@num_columns == rows[i].size
			# ensures that matrix is nxn
			raise "Matrix not tridiagonal: matrix not square" unless 
					@num_rows == rows[i].size
			for j in 0..rows[i].size do 
				case i
					when j - 1
						upper_diag << rows[i][j]
					when j
						middle_diag << rows[i][j]
					when j + 1
						lower_diag << rows[i][j]
					else 
						raise "Matrix not tridiagonal: does not obey upper and lower Hessenberg matrix properties" unless rows[i][j] == 0
				end		
			end
		end 

		#POST
		diagonal_array_sizes()
		
		#INVARIANT
		new upper_diag, middle_diag, lower_diag
	end

	# def self.build(*row_count)
	# 	return :to_enum unless block_given?
	# 	upper = Array.new(row_count[0] - 1) { |x| yield x, x + 1 }
	# 	middle = Array.new(row_count[0]) { |x| yield x, x }
	# 	lower = Array.new(row_count[0] - 1) { |x| yield x + 1, x }
	# 	new upper, middle, lower
	# end

	def self.identity(size)
		scalar(size, 1)
	end

	def self.scalar(n, value)
		#INVARIANT
		
		#PRE
		size_constraint(n)

		new Array.new(n-1) { 0 }, Array.new(n) { value }, Array.new(n-1) { 0 }

		#POST
		#INVARIANT
	end 
	
	def initialize(upper_diag, middle_diag, lower_diag)
		#PRE/POST/INVARIANT covered by self methods above
		@upper_diagonal = upper_diag
		@middle_diagonal = middle_diag
		@lower_diagonal = lower_diag
		self
	end

	# overwrite methods by matrix
	def ==(other_object) 
		return false unless TriDiagonalMatrix === other_object && 
			other_object.respond_to?(:upper_diagonal) && 
			other_object.respond_to?(:middle_diagonal) && 
			other_object.respond_to?(:lower_diagonal) && 
			@upper_diagonal.eql?(other_object.upper_diagonal) &&
			@middle_diagonal.eql?(other_object.middle_diagonal) &&
			@lower_diagonal.eql?(other_object.lower_diagonal)
	end
	
	def eql?(other_object)
		return false unless TriDiagonalMatrix === other_object && 
			other_object.respond_to?(:upper_diagonal) && 
			other_object.respond_to?(:middle_diagonal) && 
			other_object.respond_to?(:lower_diagonal) && 
			@upper_diagonal.eql?(other_object.upper_diagonal) &&
			@middle_diagonal.eql?(other_object.middle_diagonal) &&
			@lower_diagonal.eql?(other_object.lower_diagonal)
	end
	
	def +(other_matrix)
		#INVARIANT

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		addition(other_matrix)
		
		#POST
		# ensure that the dimensions of the matrix are the same
		# check_dimensions(return_matrix)
		#INVARIANT
	end
	
	def -(other_matrix)
		#INVARIANT

		#PRE
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)
		
		subtraction(other_matrix)
		
		#Post
		# ensure that the dimensions of the matrix are the same
		# check_dimensions(return_matrix)
		#INVARIANT

	end
	
	def *(other_matrix)
		#INVARIANT

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)
		
		multiplication(other_matrix)
		#POST
		# ensure that the dimensions of the matrix are the same
		# check_correct_dimensions_after_multiplication(other_matrix, return_matrix)
		#INVARIANT

	end
	
	def /(other_matrix)
		#INVARIANT

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		division(other_matrix)
		
		#POST
		# ensure that the dimensions of the matrix are the same
		# check_correct_dimensions_after_multiplication(other_matrix, return_matrix)
		#INVARIANT
		
	end


	def determinant
		#INVARIANT
		#PRE - not necessary to check if square, since tridiagonal matrices are square
		#POST
		#INVARIANT

		# @middle_diagonal[1..-1].zip(@upper_diagonal, @lower_diagonal).reduce([1, @middle_diagonal[0]]) do |c, x|
		# 	c << x[0] * c.last - x[1] * x[2] * c[-2]
		# end.last
	end
		
# 	def transpose!
# 		@upper_diagonal, @lower_diagonal = @lower_diagonal, @upper_diagonal
# 		self
# 	end

	def transpose
		#INVARIANT

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		upper = @upper_diagonal.copy
		@upper_diagonal = @lower_diagonal.copy
		@lower_diagonal = upper

		#POST

		#INVARIANT
	end 

	def [](i, j)
		case i
			when j - 1
				return @upper_diagonal[i]
			when j
				return @middle_diagonal[j]
			when j + 1
				return @lower_diagonal[j]
			else
				return 0
		end
	end

	def row_count
		@middle_diagonal.size
	end

	def to_s
		"#{self.class.name}#{to_a}"
	end

	def to_a
		Array.new(row_count) { |i|	row(i).to_a }
	end

	def row(i)
		return self unless i < row_count
		row = Array.new(row_count) { |j| self[i, j] }
		row.each(&Proc.new) if block_given?
		Vector.elements(row, false)
	end

	def map
		# return to_enum :map unless block_given?
		# block = Proc.new
		# TridiagonalMatrix.send(:new, @upper_diagonal.map(&block), @middle_diagonal.map(&block), @lower_diagonal.map(&block))
	end
	
	
	

# 	def diagonal?
# 		@upper_diagonal.all? { |x| x == 0 } && @lower_diagonal.all? { |x| x == 0 }
# 	end

# 	def toeplitz?
# 		@upper_diagonal.reduce(true) { |a, e| a && e == @upper_diagonal[0] }
# 	end

	# def upper_triangular?
	# 	false
	# end

	def square?
		true
	end

	def orthogonal?
		transpose == inverse
	end

	def symmetric?
		self == transpose
	end
	
	# all private methods
	
	private 

	def size_constraint()
		raise "Improper matrix size given" unless n > 0
	end 

	def diagonal_array_sizes()
		raise "The diagonal arrays are of improper size" unless 
			@middle_diagonal.size == @upper_diagonal.size+2 and @middle_diagonal.size == @lower_diagonal.size+2
	end

	def check_tridiagonality(other_matrix)
		raise "Other object is not tridiagonal" unless TriDiagonalMatrix === other_matrix
	end

	def check_dimensions(other_matrix)
		raise "Matricies do not have the same dimentions" unless @middle_diagonal.size == other_matrix.get_middle_diagonal.size
	end

	def addition(other_matrix)
		upper = [@upper_diagonal, other_matrix.get_upper_diagonal].transpose.map {|x| x.reduce(:+)}
		middle = [@middle_diagonal, other_matrix.get_middle_diagonal].transpose.map {|x| x.reduce(:+)}
		lower = [@lower_diagonal, other_matrix.get_lower_diagonal].transpose.map {|x| x.reduce(:+)}
	end

	def subtraction(other_matrix)
		upper = [@upper_diagonal, other_matrix.get_upper_diagonal].transpose.map {|x| x.reduce(:-)}
		middle = [@middle_diagonal, other_matrix.get_middle_diagonal].transpose.map {|x| x.reduce(:-)}
		lower = [@lower_diagonal, other_matrix.get_lower_diagonal].transpose.map {|x| x.reduce(:-)}
	end 

	def division(other_matrix)
		# if other_matrix.respond_to?("inverse")
		# 	self * other_matrix.inverse
		# else 
		# 	map {|x| x/other_matrix}	
		# end
	end

	def multiplication(other_matrix)
		# return Matrix.send(:new, Array.new(row_count) do |i|
		# 	Array.new(other.column_count) do |j|
		# 		e0 = (i == 0 ? 0 : self[i, i - 1] * other[i - 1, j])
		# 		e1 = self[i, i] * other[i, j]
		# 		e2 = (i == row_count - 1 || i == other.column_count - 1 ? 0 : self[i, i + 1] * other[i + 1, j])
		# 		e0 + e1 + e2
		# 	end
		# end) if other.respond_to?(:each)
		# map { |x| x * other }
	end
	
	def check_correct_dimensions_after_multiplication(othermatrix, result)
		raise "Multiplication dimensions are incorrect." unless @num_rows == result.num_rows && @num_columns == result.num_columns
	end

	alias_method :column_count, :row_count
	alias_method :det, :determinant
	# alias_method :inspect, :to_s
	# alias_method :[], :get_value
	# alias_method :collect, :map
	# alias_method :lower_triangular?, :upper_triangular?
	# alias_method :tr, :trace
	alias_method :t, :transpose

end
