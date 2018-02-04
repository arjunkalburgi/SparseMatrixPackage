require 'matrix'
require_relative './sparse_matrix'

class TriDiagonalMatrix
	
	attr_reader :num_columns, :num_rows, :upper_diagonal, :middle_diagonal, :lower_diagonal
	
	def self.identity(size)
		scalar(n: size, value: 1)
	end

	def self.scalar(n:, value:)
		new Matrix.scalar(n, value)
	end 

	def initialize(input)
		case input
			when Array
				rows(input)
			when Matrix
				rows(input.to_a())
			else 
				raise "Must input Array or Matrix"
		end

		#POST
		check_diagonal_array_sizes()
	end

	def ==(other_object) 
		return false unless TriDiagonalMatrix === other_object && 
			other_object.respond_to?(:upper_diagonal) && 
			other_object.respond_to?(:middle_diagonal) && 
			other_object.respond_to?(:lower_diagonal) && 
			@upper_diagonal.eql?(other_object.upper_diagonal) &&
			@middle_diagonal.eql?(other_object.middle_diagonal) &&
			@lower_diagonal.eql?(other_object.lower_diagonal)
	end
	
	def +(other_matrix)
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		return_result_matrix = addition(self, other_matrix)
		
		#POST
		check_dimensions(return_result_matrix)
		check_opposite_order_addition(other_matrix, return_result_matrix)
		
		invariant()

		return_result_matrix
	end
	
	def -(other_matrix)
		invariant()

		#PRE
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)
		
		return_result_matrix = subtraction(other_matrix)
		
		#Post
		check_dimensions(return_result_matrix)
		
		invariant()

		return_result_matrix
	end
	
	def *(other)
		invariant()

		return_result_matrix = nil
		case other
			when TriDiagonalMatrix
				#PRE 
				check_tridiagonality(other)
				check_dimensions(other)
				
				return_result_matrix = multiplication(other)
				#POST
				check_correct_dimensions_after_multiplication(return_result_matrix)
			else
				return_result_matrix = self *(new other)
		end

		invariant()

		return_result_matrix
	end
	
	def /(other_matrix)
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		return_result_matrix = multiplication(other_matrix.getInverse)
		
		#POST
		check_correct_dimensions_after_multiplication(other_matrix, return_result_matrix)
		
		invariant()

		return_result_matrix
	end


	def determinant
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		result = determinant_method()

		#POST
		check_result_is_number(result)
		
		invariant()

		result
	end

	def transpose
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		return_result_matrix = transpose_method()

		#POST
		check_dimensions(return_result_matrix)

		invariant()

		return_result_matrix
	end 

	def inverse
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		return_result_matrix = inverse_method()

		#POST
		check_dimensions(return_result_matrix)

		invariant()

		return_result_matrix
	end

	def real
		invariant()
		
		return_result_matrix = self
		return_result_matrix.upper_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real) 
			val.real
		}
		return_result_matrix.middle_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real) 
			val.real
		}
		return_result_matrix.lower_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real) 
			val.real
		}

		check_dimensions(return_result_matrix)
		invariant()
	end

	def real?
		invariant()

		@upper_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real?) 
			return false unless val.real?
		}
		@middle_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real?) 
			return false unless val.real?
		}
		@lower_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real?) 
			return false unless val.real?
		}

		invariant()

		true
	end

	def imaginary
		invariant()
		
		return_result_matrix = self
		return_result_matrix.upper_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:imaginary) 
			val.imaginary
		}
		return_result_matrix.middle_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:imaginary) 
			val.imaginary
		}
		return_result_matrix.lower_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:imaginary) 
			val.imaginary
		}

		check_dimensions(return_result_matrix)
		invariant()
	end

	def imaginary?
		invariant()
		
		@upper_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real?) 
			return false unless !(val.real?)
		}
		@middle_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real?) 
			return false unless !(val.real?)
		}
		@lower_diagonal.map {|val| 
			raise "Must be of type Numeric to test real/imaginary" unless val.respond_to?(:real?) 
			return false unless !(val.real?)
		}

		invariant()

		true
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

	def diagonal?
		@upper_diagonal.all? { |val| val == 0 } && @lower_diagonal.all? { |val| val == 0 }
	end

	def upper_triangular?
		return false unless @upper_diagonal.any? {|val| val > 0} && @middle_diagonal.any? {|val| val > 0} && @lower_diagonal.all? {|val| val == 0}
	end

	def lower_triangular?
		return false unless @lower_diagonal.any? {|val| val > 0} && @middle_diagonal.any? {|val| val > 0} && @upper_diagonal.all? {|val| val == 0}
	end

	def square?
		true
	end

	def orthogonal?
		transpose == inverse
	end

	def symmetric?
		self == transpose
	end

	def to_a(upper: @upper_diagonal, middle: @middle_diagonal, lower: @lower_diagonal)
		array = Array.new(@num_rows){Array.new(@num_columns,0)}
		for i in 0..@num_rows-1 do 
			for j in 0..@num_columns-1 do
				case i
					when j - 1
						array[i][j] = upper[i]
					when j
						array[i][j] = middle[i]
					when j + 1
						array[i][j] = lower[j]
					else
						array[i][j] = 0
				end	
			end
		end
		array
	end

	def to_m
		Matrix.rows(to_a)
	end
	
	private 

	def rows(rows, copy = true)
		
		# rows = convert_to_array(rows, true) 
		# rows.map! { |row| convert_to_array(row, copy) }

		# basing column size on first row
		@num_columns = (rows[0] || []).size
		@num_rows = rows.size 
		
		@upper_diagonal = []
		@middle_diagonal = []
		@lower_diagonal = []
		
		#PRE
		#raise methods for preconditions included within initialization
		#to minimize loops ran
		#ensures there are 3 diagonals of proper sizes
	
		for i in 0..rows.size-1 do 
			# ensures that the input is correct
			raise "Matrix not tridiagonal: rows of various sizes" unless 
					@num_columns == rows[i].size
			# ensures that matrix is nxn
			raise "Matrix not tridiagonal: matrix not square" unless 
					@num_rows == rows[i].size
			for j in 0..rows[i].size-1 do 
				case i
					when j - 1
						@upper_diagonal << rows[i][j]
					when j
						@middle_diagonal << rows[i][j]
					when j + 1
						@lower_diagonal << rows[i][j]
					else 
						raise "Matrix not tridiagonal: does not obey upper and lower Hessenberg matrix properties" unless rows[i][j] == 0
				end		
			end
		end 

		#POST
		begin
			raise "Improper matrix size given" unless @middle_diagonal.size > 0
		end 
	end

	def invariant()
		raise "TriDiagonalMatrix does not satisfy that it should be square" unless @num_rows == @num_columns

		raise "Matrix does not satisfy A * A.getInverse() = I invariant" unless multiplication(getInverse()) == Matrix.identity(@num_rows)

		raise "Matrix does not satisfy A.getDeterminant() == 0 when I.getInverse() == null invariant" unless getDeterminant() == 0 && getInverse() == nil

		raise "Matrix does not satisfy A*I = A invariant" unless multiplication(TriDiagonalMatrix.identity(@num_columns)) == self
		raise "Matrix does not satisfy A*(0 matrix) = 0 matrix" unless multiplication(TriDiagonalMatrix.scalar(n: @num_columns, value: 0)) == TriDiagonalMatrix.scalar(@num_columns, 0)

		raise "Matrix does not satisfy A+A = 2A" unless addition(self, self) == multiplication(2)
		raise "Matrix does not satisfy A-A = 0" unless subtraction(self) == TriDiagonalMatrix.scalar(n: @num_rows, value: 0)
		raise "Matrix does not satisfy A+0 = A" unless addition(self, TriDiagonalMatrix.scalar(n: @num_rows, value: 0)) == self

		raise "Matrix must satisfy that itself is not null" unless !(@upper_diagonal.any?{|val| val.nil? } && @middle_diagonal.any?{|val| val.nil? } && @lower_diagonal.any?{|val| val.nil? })
	end

	def check_diagonal_array_sizes()
		raise "The diagonal arrays are of improper size" unless @middle_diagonal.size == @upper_diagonal.size+1 && @middle_diagonal.size == @lower_diagonal.size+1
	end

	def check_tridiagonality(other_matrix)
		raise "Other object is not tridiagonal" unless TriDiagonalMatrix === other_matrix
	end

	def check_dimensions(other_matrix)
		raise "Matricies do not have the same dimensions" unless @num_rows == other_matrix.num_rows
	end

	def check_correct_dimensions_after_multiplication(result)
		raise "Multiplication dimensions are incorrect." unless @num_rows == result.num_rows && @num_columns == result.num_columns
	end

	def check_opposite_order_addition(other_matrix, return_result_matrix)
		raise "Order should have been maintained." unless addition(other_matrix, self) == return_result_matrix
	end

	def check_result_is_number(result) 
		raise "Result is a number" unless result.is_a? Numeric
	end

	def addition(this_matrix, other_matrix)
		case other_matrix
			when Matrix
				other_matrix + this_matrix.to_m
			when TriDiagonalMatrix
				upper = [@upper_diagonal, other_matrix.upper_diagonal].transpose.map {|x| x.reduce(:+)}
				middle = [@middle_diagonal, other_matrix.middle_diagonal].transpose.map {|x| x.reduce(:+)}
				lower = [@lower_diagonal, other_matrix.lower_diagonal].transpose.map {|x| x.reduce(:+)}
				TriDiagonalMatrix.new(Matrix.rows(to_a(upper: upper, middle: middle, lower: lower)))
			else 
				raise "Addition must be with TriDiagonalMatrix or Matrix"
		end
	end

	def subtraction(other_matrix)
		case other_matrix
			when Matrix
				other_matrix - self.to_m
			when TriDiagonalMatrix
				upper = [@upper_diagonal, other_matrix.upper_diagonal].transpose.map {|x| x.reduce(:-)}
				middle = [@middle_diagonal, other_matrix.middle_diagonal].transpose.map {|x| x.reduce(:-)}
				lower = [@lower_diagonal, other_matrix.lower_diagonal].transpose.map {|x| x.reduce(:-)}
				TriDiagonalMatrix.new(Matrix.rows(to_a(upper: upper, middle: middle, lower: lower)))
			else 
				raise "Subtraction must be with TriDiagonalMatrix or Matrix"
		end
	end 

	def multiplication(other)
		case other
			when Numeric
				TriDiagonalMatrix.new(Matrix.rows(self.to_a) * other)
			when Matrix
				Matrix.rows(self.to_a) * other
			when TriDiagonalMatrix
				SparseMatrix.new(Matrix.rows(self.to_a) * Matrix.rows(other.to_a))
			when SparseMatrix
				SparseMatrix.new(Matrix.rows(self.to_a) * Matrix.rows(other.to_a))
			else 
				raise "Must multiply by scalar, matrix, sparse matrix, or tridiagonal matrix"
		end
	end

	def getDeterminant()
		Matrix.rows(to_a).determinant
	end

	def getTranspose()
		TridiagonalMatrix.new(Matrix.rows(to_a(upper: @lower_diagonal, middle: @middle_diagonal, lower: @upper_diagonal)))
	end 

	def getInverse()
		begin
			Matrix.rows(to_a).inverse
		rescue
			nil
		end 
	end

	alias_method :det, :determinant
	alias_method :t, :transpose
	alias_method :eql?, :==

end
