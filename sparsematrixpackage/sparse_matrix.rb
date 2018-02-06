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
	
	def initialize(input, rows=nil, columns=nil)
		#add a way to handle blank creation (ie .new(2,3) gives 2x3 blank matrix)
		case input 
			when Array 
				rows(input)
			when Matrix
				rows(input.to_a)
			when Hash
				@matrix_table = input
				if input.keys.size > 0 && rows==nil && columns==nil
					# assume the maximum row and col given gives the dimensions in zero index, +1 to 1 index
					@num_rows = input.keys.map{|key| key[:row]}.max + 1
					@num_columns = input.keys.map{|key| key[:column]}.max + 1
				elsif rows==nil && columns==nil
					raise "Must either define dimensions via input or explicitly passing arguments."
				else 
					@num_rows = rows
					@num_columns = columns
				end
				removeZeroElements
			else 
				raise "Input must be of type Array (array of arrays), Matrix or Hash."
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
		check_matching_dimensions(other_matrix)
		
		result_matrix = addition(self, other_matrix)

		check_dimensions_are_the_same(result_matrix)
		check_opposite_order_addition(other_matrix, result_matrix)
		invariant

		result_matrix
	end
	
	def -(other_matrix)
		invariant
		check_matching_dimensions(other_matrix)
		
		result_matrix = subtraction(other_matrix)

		check_dimensions_are_the_same(result_matrix)
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
				check_compatible_dimensions_for_multiplication(other.getInverse)

				result_matrix = multiplication(other.getInverse)

				check_correct_dimensions_after_multiplication(other.getInverse, result_matrix)
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

			def equals(this_matrix, other_matrix)
				(this_matrix.matrix_table == other_matrix.matrix_table)
			end

			def addition(this_matrix, other_matrix)
				hash_result = this_matrix.matrix_table.merge(other_matrix.matrix_table) {|key,vala,valb| vala+valb}
				SparseMatrix.new(hash_result)
			end
 
			def subtraction(other_matrix)
				temp = other_matrix.matrix_table.clone
				hash_result = @matrix_table.merge(temp.each {|k,v| temp[k]=v*-1}) {|key,vala,valb| vala+valb}
				SparseMatrix.new(hash_result, @num_rows, @num_columns)
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

	alias_method :det, :determinant
	alias_method :t, :transpose
	alias_method :eql?,  :==
	alias_method :[] :get
	alias_method :[]= :put
	alias_method :set :put
end

