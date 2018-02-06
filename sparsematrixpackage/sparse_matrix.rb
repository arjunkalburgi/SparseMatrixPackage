require 'matrix'
require_relative './tridiagonal_matrix'

class SparseMatrix

	attr_reader :matrix_table, :num_rows, :num_columns

	def self.identity(size)
		scalar(size, 1)
	end

	def self.scalar(n, value)
		new Matrix.scalar(n, value)
	end
	
	def initialize(*args)
		#add a way to handle blank creation (ie .new(2,3) gives 2x3 blank matrix) input={}, rows=nil, columns=nil
		if args.size == 1
			case args[0]
				when Array 
					from_array(args[0])
				when Matrix
					from_matrix(args[0])
				when Hash
					@matrix_table = args[0]
					if args[0].keys.size > 0
						# assume the maximum row and col given gives the dimensions in zero index, +1 to 1 index
						@num_rows = args[0].keys.map{|key| key[:row]}.max + 1
						@num_columns = args[0].keys.map{|key| key[:column]}.max + 1
					end
				when TriDiagonalMatrix
					from_array(args[0].to_a)
				else 
					raise "Single input must be of type Array (array of arrays), Matrix or Hash."		
			end 
		elsif args.size == 3
			check_input_dimensions(args[1],args[2])
			@matrix_table = args[0]
			@num_rows = args[1]
			@num_columns = args[2]
			removeZeroElements
		elsif args.size == 2
			init_default(*args)
		else 
			raise "Only accepts 1, 2 or 3 arguments."
		end
	end 
	
	def ==(other_matrix)
		invariant
		check_matching_dimensions(other_matrix)
		
		result = equals(self, other_matrix)
		
		invariant

		result
	end
	
	def +(other_matrix)
		invariant

		result_matrix = nil
		case other_matrix
			when SparseMatrix
				check_matching_dimensions(other_matrix)
				
				result_matrix = addition(self, other_matrix)

				check_dimensions_are_the_same(result_matrix)
				check_opposite_order_addition(other_matrix, result_matrix)
				
			else 
				result_matrix = addition(other)
		end

		invariant

		result_matrix
	end
	
	def -(other_matrix)
		invariant

		result_matrix = nil
		case other_matrix
			when SparseMatrix
				check_matching_dimensions(other_matrix)
		
				result_matrix = subtraction(other_matrix)

				check_dimensions_are_the_same(result_matrix)
				
			else 
				result_matrix = subtraction(other)
		end
		
		invariant

		result_matrix
	end
	
	def *(other)
		invariant

		result_matrix = nil
		case other
			when SparseMatrix
				check_compatible_dimensions_for_multiplication(other)
				
				result_matrix = multiplication(other)

				check_correct_dimensions_after_multiplication(other, result_matrix)
				
			else 
				result_matrix = multiplication(other)
		end

		invariant

		result_matrix
	end
	
	def /(other)
		invariant

		case other
			when SparseMatrix
				check_compatible_dimensions_for_multiplication(other.inverse)

				result_matrix = multiplication(other.inverse)

				check_correct_dimensions_after_multiplication(other.inverse, result_matrix)
			else 
				result_matrix = multiplication(1.0/other)
		end

		invariant

		result_matrix
	end
	
	def determinant
		invariant
		check_square_matrix
		
		result = getDeterminant

		check_result_is_number(result)
		invariant

		result
	end
	
	def transpose
		invariant

		result_matrix = getTranspose
		
		check_correct_dimensions_after_transpose(result_matrix, {row: @num_rows, column: @num_columns})
		invariant

		result_matrix
	end
	
	def inverse
		invariant
		check_square_matrix
		
		result_matrix = getInverse

		check_square_matrix
		invariant

		result_matrix
	end

	def real 
		invariant

		result_matrix = self
		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real)
			result_matrix[key] = @matrix_table[key].real
		end

		check_dimensions_are_the_same(result_matrix)
		invariant

		result_matrix
	end

	def real?
		invariant

		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real?)
			return false unless @matrix_table[key].real?
		end

		invariant

		true
	end
	
	def imaginary 
		invariant

		result_matrix = self
		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:imaginary)
			result_matrix[key] = @matrix_table[key].imaginary
		end

		check_dimensions_are_the_same(result_matrix)
		invariant

		result_matrix
	end

	def imaginary?
		invariant

		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real?)
			return false unless !(@matrix_table[key].real?)
		end

		invariant

		true 
	end

	def square? 
		@num_rows == @num_columns
	end

	def zero? 
		removeZeroElements
		@matrix_table.empty? 
	end

	def [](row, column)
		@matrix_table[{row: row, column: column}]
	end

	def to_a
		array = Array.new(@num_rows){Array.new(@num_columns,0)}
		@matrix_table.keys.each do |key|
			array[key[:row]][key[:column]] = @matrix_table[key]
		end
		array
	end
	
	def to_s
		"#{self.class.name}#{to_a}"
	end

	def to_m 
		Matrix.rows(to_a)
	end
	
	def get(r, c)
		invariant
		
		check_valid_coordinates(r, c)

		@matrix_table[{row: r, column: c}]
	end
	
	def set(r, c, v)
		invariant
		
		check_valid_coordinates(r, c)

		@matrix_table[{row: r, column: c}] = v

		invariant		
	end
	
	def dimensions
		invariant
		
		[@num_rows, @num_columns]
	end

	def each(which = :all, &block) 
		invariant
		
		return to_enum :each, which unless block_given?
		case which
			when :non_zero  
				@matrix_table.each{|k,v| block.call(v)}
			else 
				# must pass to matrix since 0 elements are not present
				# handles :all :diagonal, :off_diagonal, :lower, :strict_lower, :upper, :strict_upper
				# anything missed? matrix might implement it (when :row, :column, :regular)
				to_m.each(which, &block)
		end
	end 

	def map(&block)
		invariant
		
		return to_enum(:collect) unless block_given?
		temp = @matrix_table.clone
		temp.map{|k,v| temp[k]=block.call(v)}
		SparseMatrix.new(temp, @num_rows, @num_columns)
	end
	
	def row(i)
		invariant 

		check_valid_coordinates(i, 0)

		arr = []
		(0..@num_columns-1).each do |c|
			arr.push(@matrix_table[{row: i, column: c}])
		end
		arr
	end
	
	def column(i)
		invariant 

		check_valid_coordinates(0, i)

		arr = []
		(0..@num_rows-1).each do |r|
			arr.push(@matrix_table[{row: r, column: i}])
		end
		arr
	end

	private

	# FUNCTIONALITY			
		def rows(matrixarray)

			@num_rows = matrixarray.size
			@num_columns = matrixarray[0].size

			@matrix_table = Hash.new(0)
			matrixarray.each_index do |i|
				raise "Not all columns are the same size." unless matrixarray[i].size == @num_columns 
				matrixarray[i].each_index do |j|
					if matrixarray[i][j] != 0
						@matrix_table[{row: i, column: j}] = matrixarray[i][j]
					end
				end
			end

		end

		def init_default(*args)
			check_input_dimensions(args[0],args[1])

			@matrix_table = Hash.new(0)
			@num_rows = args[0]
			@num_columns = args[1]
		end

		def from_matrix(matrix)
			rows(matrix.to_a)
		end

		def from_array(array)
			rows(array)
		end	

		def equals(this_matrix, other_matrix)
			other_matrix.respond_to?(:matrix_table) && 
			other_matrix.respond_to?(:num_rows) && 
			other_matrix.respond_to?(:num_columns) && 
			this_matrix.matrix_table == (other_matrix.matrix_table) &&
			this_matrix.num_rows.eql?(other_matrix.num_rows) &&
			this_matrix.num_columns.eql?(other_matrix.num_columns)
		end

		def addition(this_matrix, other_matrix)
			case other_matrix
				when Matrix
					SparseMatrix.new(Matrix.rows(to_a) + other_matrix)
				when TriDiagonalMatrix
					SparseMatrix.new(TriDiagonalMatrix.new(to_a) + other_matrix)
				when SparseMatrix
					hash_result = this_matrix.matrix_table.merge(other_matrix.matrix_table) {|key,vala,valb| vala+valb}
					SparseMatrix.new(hash_result, @num_rows, @num_columns)
				else 
					raise "Must add by matrix, sparse matrix, or tridiagonal matrix"
			end
		end

		def subtraction(other_matrix)
			case other_matrix
				when Matrix
					SparseMatrix.new(Matrix.rows(to_a) - other_matrix)
				when TriDiagonalMatrix
					SparseMatrix.new(TriDiagonalMatrix.new(to_a) - other_matrix)
				when SparseMatrix
					temp = other_matrix.matrix_table.clone
					hash_result = @matrix_table.merge(temp.each {|k,v| temp[k]=v*-1}) {|key,vala,valb| vala+valb}
					SparseMatrix.new(hash_result, @num_rows, @num_columns)
				else
					raise "Must subtract by matrix, sparse matrix, or tridiagonal matrix"
			end
		end

		def multiplication(other)
			case other
				when Numeric
					temp = @matrix_table.clone 
					SparseMatrix.new(temp.each {|k,v| temp[k]=v*other}, @num_rows, @num_columns)
				when Matrix
					SparseMatrix.new(Matrix.rows(to_a) * other)
				when TriDiagonalMatrix
					SparseMatrix.new(Matrix.rows(to_a) * Matrix.rows(other.to_a))
				when SparseMatrix
					if other.zero? or zero?
						return SparseMatrix.new(Hash.new(0), @num_rows, other.num_columns)
					end
					SparseMatrix.new(Matrix.rows(to_a) * Matrix.rows(other.to_a))
				else 
					raise "Must multiply by scalar, matrix, sparse matrix, or tridiagonal matrix"
			end
		end

		def getDeterminant
			Matrix.rows(to_a).determinant
		end

		def getInverse
			begin 
				SparseMatrix.new(Matrix.rows(to_a).inverse)
			rescue
				nil
			end 
		end

		def getTranspose
			SparseMatrix.new(Matrix.rows(to_a).transpose)
		end

		def removeZeroElements 
			@matrix_table.delete_if {|k,v| v==0}
		end 

	
	# TESTS
			def invariant
				if square?
					identitymatrix = SparseMatrix.identity(@num_rows)
					if getInverse
						raise "Matrix does not satisfy A * A.inverse = I invariant" unless equals(multiplication(getInverse), identitymatrix)
					else
						raise "Matrix does not satisfy A.getDeterminant == 0 when I.inverse == null invariant" unless getDeterminant == 0 && getInverse == nil
					end
				end

				raise "Matrix does not satisfy A*I = A invariant" unless equals(multiplication(SparseMatrix.identity(@num_columns)), itself)

				raise "Matrix does not satisfy A+A = 2A" unless equals(addition(itself, itself), multiplication(2))
				raise "Matrix does not satisfy A-A = 0" unless equals(subtraction(itself), SparseMatrix.new(Hash.new(0), @num_rows, @num_columns))
				raise "Matrix does not satisfy A+0 = A" unless equals(addition(itself, SparseMatrix.new(Hash.new(0), @num_rows, @num_columns)), itself)
				raise "Matrix does not satisfy A*0 = 0" unless equals(multiplication(SparseMatrix.new(Hash.new(0), @num_rows, @num_columns)), SparseMatrix.new(Hash.new(0), @num_rows, @num_columns))

				raise "Matrix must satisfy that itself is not null" unless !(@matrix_table.nil? && @matrix_table.values.any?{|val| val.nil? })
			end

			def check_matching_dimensions(other_matrix)
				raise "Cannot perform operation, deminsions do not match." unless @num_rows == other_matrix.num_rows && @num_columns == other_matrix.num_columns
			end

			def check_dimensions_are_the_same(result)
				raise "Matrix dimensions must remain the same." unless @num_rows == result.num_rows && @num_columns == result.num_columns
			end

			def check_compatible_dimensions_for_multiplication(other_matrix) 
				raise "Cannot perform operation, deminsions are not compatible." unless @num_columns == other_matrix.num_rows
				# {row: @num_rows, column: other_matrix.num_columns}
			end

			def check_correct_dimensions_after_multiplication(other_matrix, result)
				raise "Multiplication dimensions are incorrect." unless result.num_rows == @num_rows && result.num_columns == other_matrix.num_columns
			end

			def check_square_matrix
				raise "Cannot perform operation, matrix not square." unless @num_columns == @num_rows
			end

			def check_result_is_number(result) 
				raise "Result is a number" unless result.is_a? Numeric
			end

			def check_correct_dimensions_after_transpose(result, current_dimensions) 
				raise "Incorrect matrix dimensions." unless current_dimensions[:row] == @num_columns && @num_rows == current_dimensions[:column]
			end

			def check_opposite_order_addition(other_matrix, result_matrix)
				raise "Matricies do not support opposite order addition" unless equals(result_matrix, addition(other_matrix, self))
			end

			def check_input_dimensions(row,col)
				raise "Matrix dimensions must be greater than 0" unless row > 0 && col > 0
			end

			def check_valid_coordinates(row, col)
				raise "Coordinates must be greater or equal to 0 and less than the dimensions" unless row >= 0 && col >= 0 && row < @num_rows && col < @num_columns
			end

	alias_method :det, :determinant
	alias_method :t, :transpose
	alias_method :eql?,  :==
	alias_method :[], :get
	alias_method :[]=, :set
	alias_method :put, :set 
end

