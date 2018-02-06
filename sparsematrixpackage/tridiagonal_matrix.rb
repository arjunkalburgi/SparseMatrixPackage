require 'matrix'
# require_relative './sparse_matrix'

class TriDiagonalMatrix

	include Enumerable
	
	attr_reader :column_count, :row_count, :upper_diagonal, :middle_diagonal, :lower_diagonal
	
	def self.identity(size)
		scalar(n: size, value: 1)
	end

	def self.scalar(n:, value:)
		new Matrix.scalar(n, value)
	end 

	def initialize(*args)
		if args.size == 1
			if args[0].respond_to?(:to_a)
				rows(args[0].to_a)
			else 
				raise "Must be able to convert to an array to be made into a TriDiagonalMatrix"
			end
		elsif args.size == 3
			init_diagonals(*args)
		else
			init_default(*args)
		end

		#POST
		check_diagonal_array_sizes(@upper_diagonal, @middle_diagonal, @lower_diagonal)
	end

	def ==(other_object) 
		TriDiagonalMatrix === other_object && 
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
		check_dimensions(other_matrix)
		
		return_result_matrix = subtraction(other_matrix)
		
		#Post
		check_dimensions(return_result_matrix)
		
		invariant()

		return_result_matrix
	end
	
	def *(other)
		invariant()
		
		#PRE
		check_dimensions(other) if other.respond_to?(:row_count)

		if other.respond_to?(:row_count)
			return_result_matrix = multiplication(other)		
		else 
			return_result_matrix = map { |x| x * other }
		end

		#POST
		check_correct_dimensions_after_multiplication(return_result_matrix)

		invariant()

		return_result_matrix
	end
	
	def /(other)
		invariant()

		#PRE
		check_dimensions(other) if other.respond_to?(:row_count)

		if other.respond_to?(:inverse) 
			return_result_matrix = multiplication(other.inverse)
		else 
			return_result_matrix = map { |x| x / other }
		end
		
		#POST
		check_correct_dimensions_after_multiplication(return_result_matrix)
		
		invariant()

		return_result_matrix
	end


	def determinant
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		result = getDeterminant()

		#POST
		check_result_is_number(result)
		
		invariant()

		result
	end

	def transpose
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		return_result_matrix = getTranspose()

		#POST
		check_dimensions(return_result_matrix)

		invariant()

		return_result_matrix
	end 

	def inverse
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		return_result_matrix = getInverse()

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

	def get(i, j)
		invariant()

		#PRE
		check_coordinates(i,j)

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

	def put(i, j, v)
		invariant()

		#PRE
		check_coordinates(i,j)

		case i
			when j - 1
				@upper_diagonal[i] = v
			when j
				@middle_diagonal[j] = v
			when j + 1
				@lower_diagonal[j] = v
			else
				raise "Matrix would not obey upper and lower Hessenberg matrix properties by setting this value"
		end

		invariant()
	end

	def dimensions
		return [self.row_count, self.column_count]
	end

	def trace
		invariant()

		result = @middle_diagonal.reduce(:+)

		#POST
		check_result_is_number(result)
		
		invariant()

		result
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

	def to_a
		array = Array.new(@row_count){Array.new(@column_count,0)}
		for i in 0..@row_count-1 do 
			for j in 0..@column_count-1 do
				case i
					when j - 1
						array[i][j] = @upper_diagonal[i]
					when j
						array[i][j] = @middle_diagonal[i]
					when j + 1
						array[i][j] = @lower_diagonal[j]
					else
						array[i][j] = 0
				end	
			end
		end
		array
	end

	def to_m
		Matrix.rows(self.to_a)
	end

	def to_s
		"#{self.class.name}#{to_a}"
	end

	def map
		invariant()
		return to_enum(:map) unless block_given?
		block = Proc.new
		TriDiagonalMatrix.new(@upper_diagonal.map(&block), @middle_diagonal.map(&block), @lower_diagonal.map(&block))
	end

	def row(i)
		invariant()
		return self unless i < @row_count
		Array.new(@row_count) { |j| self[i, j] }
	end

	def column(j)
		invariant()
		return self unless j < @column_count
		Array.new(@column_count) { |i| self[i, j] }
	end

	def each(which = :all, &block) 
		invariant()
		return to_enum :each, which unless block_given?
		case which
			when :non_zero  
				combine = @upper_diagonal + @middle_diagonal + @lower_diagonal
				combine.each{|k,v| block.call(v)}
			when :diagonal
				@middle_diagonal.each{|k,v| block.call(v)}
			else 
				to_m.each(which, &block)
		end
	end
	
	private 

	def rows(rows)

		# basing column size on first row
		@column_count = (rows[0] || []).size
		@row_count = rows.size 
		
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
					@column_count == rows[i].size
			# ensures that matrix is nxn
			raise "Matrix not tridiagonal: matrix not square" unless 
					@row_count == rows[i].size
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

	def init_default(*args) 
		#PRE 
		check_input_dimensions(args[0],args[1])

		@row_count = args[0]
		@column_count = args[1]
		
		@upper_diagonal = Array.new(@row_count-1,0)
		@middle_diagonal = Array.new(@row_count,0)
		@lower_diagonal = Array.new(@row_count-1,0)
	end

	def init_diagonals(*args) 
		#PRE 
		check_diagonal_array_sizes(args[0],args[1],args[2])
		
		@upper_diagonal = args[0]
		@middle_diagonal = args[1]
		@lower_diagonal = args[2]

		@row_count = @middle_diagonal.size
		@column_count = @middle_diagonal.size
	end

	def invariant
		raise "TriDiagonalMatrix does not satisfy that it should be square" unless @row_count == @column_count

		raise "Matrix does not satisfy A * A.getInverse() = I invariant" unless multiplication(getInverse()) == Matrix.identity(@row_count)

		# raise "Matrix does not satisfy A.getDeterminant() == 0 when I.getInverse() == null invariant" unless getDeterminant() == 0 && getInverse() == nil
		
		raise "Matrix does not satisfy A*I = A invariant" unless multiplication(TriDiagonalMatrix.identity(@column_count)) == self.to_m
		raise "Matrix does not satisfy A*(0 matrix) = 0 matrix" unless multiplication(TriDiagonalMatrix.scalar(n: @column_count, value: 0)) == Matrix.scalar(@column_count, 0)

		raise "Matrix does not satisfy A+A = 2A" unless addition(self, self) == multiplication(2)
		raise "Matrix does not satisfy A-A = 0" unless subtraction(self) == TriDiagonalMatrix.scalar(n: @row_count, value: 0)
		raise "Matrix does not satisfy A+0 = A" unless addition(self, TriDiagonalMatrix.scalar(n: @row_count, value: 0)) == self

		raise "Matrix must satisfy that itself is not null" unless !(@upper_diagonal.any?{|val| val.nil? } && @middle_diagonal.any?{|val| val.nil? } && @lower_diagonal.any?{|val| val.nil? })
	end

	def check_diagonal_array_sizes(upper, middle, lower)
		raise "The diagonal arrays are of improper size to make a TriDiagonalMatrix" unless middle.size == upper.size+1 && middle.size == lower.size+1
	end

	def check_tridiagonality(other_matrix)
		raise "Other object is not tridiagonal" unless TriDiagonalMatrix === other_matrix
	end

	def check_dimensions(other_matrix)
		raise "Matricies do not have the same dimensions" unless @row_count == other_matrix.row_count
	end

	def check_input_dimensions(row,col)
		raise "Matrix dimensions must be greater than 0 and square" unless row > 0 && col > 0 && row == col
	end

	def check_correct_dimensions_after_multiplication(result)
		if result.respond_to?(:row_count)
			raise "Multiplication dimensions are incorrect." unless @row_count == result.row_count && @column_count == result.column_count
		# else 
		# 	raise "Multiplication dimensions are incorrect. Could not properly check dimensions." 
		end
	end

	def check_opposite_order_addition(other_matrix, return_result_matrix)
		raise "Order should have been maintained." unless addition(other_matrix, self).to_m == return_result_matrix.to_m
	end

	def check_result_is_number(result) 
		raise "Result is a number" unless result.is_a? Numeric
	end

	def check_coordinates(i,j)
		raise "Out of coordinate matrix range" unless i >= 0 && j >= 0 && i < @row_count && j < @column_count
	end

	def addition(this_matrix, other_matrix)
		case other_matrix
			when Matrix
				other_matrix + this_matrix.to_m
			when TriDiagonalMatrix
				upper = [this_matrix.upper_diagonal, other_matrix.upper_diagonal].transpose.map {|x| x.reduce(:+)}
				middle = [this_matrix.middle_diagonal, other_matrix.middle_diagonal].transpose.map {|x| x.reduce(:+)}
				lower = [this_matrix.lower_diagonal, other_matrix.lower_diagonal].transpose.map {|x| x.reduce(:+)}
				TriDiagonalMatrix.new(upper, middle, lower)
			else 
				raise "Addition must be with TriDiagonalMatrix or Matrix"
		end
	end

	def subtraction(other_matrix)
		case other_matrix
			when Matrix
				other_matrix*(-1) + self.to_m
			when TriDiagonalMatrix
				upper = [@upper_diagonal, other_matrix.upper_diagonal].transpose.map {|x| x.reduce(:-)}
				middle = [@middle_diagonal, other_matrix.middle_diagonal].transpose.map {|x| x.reduce(:-)}
				lower = [@lower_diagonal, other_matrix.lower_diagonal].transpose.map {|x| x.reduce(:-)}
				TriDiagonalMatrix.new(upper, middle, lower)
			else 
				raise "Subtraction must be with TriDiagonalMatrix or Matrix"
		end
	end 

	def multiplication(other)
		case other
			when Numeric
				TriDiagonalMatrix.new(self.to_m * other)
			when Matrix
				self.to_m * other
			when TriDiagonalMatrix
				self.to_m * other.to_m
			else 
				raise "Must multiply by scalar, matrix, or tridiagonal matrix"
		end
	end

	def getDeterminant
		self.to_m.determinant
	end

	def getTranspose
		TriDiagonalMatrix.new(@lower_diagonal, @middle_diagonal, @upper_diagonal)
	end 

	def getInverse
		begin
			self.to_m.inverse
		rescue
			nil
		end 
	end

	alias_method :det, :determinant
	alias_method :t, :transpose
	alias_method :tr, :trace
	alias_method :eql?, :==
	alias_method :[], :get
	alias_method :[]=, :put
	alias_method :set, :put

end
