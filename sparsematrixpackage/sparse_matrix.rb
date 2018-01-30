# definition for the sparse matrix class
require 'matrix'

class SparseMatrix

	# let matrix handle these functions
	# delegate [:**, :hermitian?, :normal?, :permutation?] => :Matrix.send(:new, to_a)

	attr_reader :matrix_table, :num_rows, :num_columns

	def self.rows(matrixarray)

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

	def self.identity(size)
		(0..size).each do |i|
			@matrix_table[{row: i, col: i}] = 1
		end
	end

	def self.scalar(n, value)
		(0..n).each do |i|
			@matrix_table[{row: i, col: i}] = value
		end
	end 
	
	def initialize(input)
		case input 
			when Array 
				self.rows(input)
			when Matrix
				self.rows(inputs.to_a())
			when Hash
				@matrix_table = input
				# assume the maximum row and col given gives the dimensions (to be changed in proper implementation)
				@num_rows = input.keys.map{|key| key[:row]}.max
				@num_columns = input.keys.map{|key| key[:column]}.max
			else 
		end
	end
	
	def +(othermatrix)
		invariant()
		check_matching_dimensions(othermatrix)
		
		resultmatrix = addition(othermatrix)
		# matrix = othermatrix.matrix_table
		
		# all_keys_with_value = @matrix_table.keys + matrix.keys

		# all_keys_with_value.each do |key| 
		# 	@matrix_table[key] += matrix[key]
		# end

		check_dimensions_are_the_same(resultmatrix)
		invariant()
	end
	
	def -(othermatrix)
		invariant()
		check_matching_dimensions(othermatrix)
		
		resultmatrix = subtraction(othermatrix)
		# matrix = othermatrix.matrix_table
		# all_keys_with_value = @matrix_table.keys + matrix.keys

		# all_keys_with_value.each do |key| 
		# 	@matrix_table[key] -= matrix[key]
		# end

		check_dimensions_are_the_same(resultmatrix)
		invariant()
	end
	
	def *(othermatrix)
		invariant()
		check_compatible_dimensions_for_multiplication(othermatrix)
		
		resultmatrix = multiplication(othermatrix)

		check_correct_dimensions_after_multiplication(othermatrix, resultmatrix)
		invariant()
	end
	
	def /(othermatrix)
		invariant()
		check_compatible_dimensions_for_multiplication(othermatrix.getInverse())

		resultmatrix = multiplication(othermatrix.getInverse())

		check_correct_dimensions_after_multiplication(othermatrix.getInverse())
		invariant()
	end
	
	def getDeterminant()
		invariant()
		check_square_matrix()
		
		determinant = getMatrixDeterminant()

		check_result_is_number(determinant)
		invariant()
	end
	
	def getInverse()
		invariant()
		check_square_matrix()
		
		resultmatrix = inverse()

		check_square_matrix()
		# raise "Inverse Matrix must obey A*A.inv = I property" unless (A * A.getInverse()) == 
		invariant()
	end
	
	def getTranspose()
		invariant()

		resultmatrix = transpose()
		
		check_correct_dimensions_after_transpose(resultmatrix, {row: @num_rows, column: @num_columns})
		invariant()
	end
	
	def ==(othermatrix)
		invariant()
		check_matching_dimensions(othermatrix)
		
		result = (@matrix_table == othermatrix.matrix_table)
		
		invariant()
	end

	def real() 
		invariant()

		resultmatrix = self
		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real)
			resultmatrix[key] = @matrix_table[key].real
		end

		check_dimensions_are_the_same(resultmatrix)
		invariant()
	end

	def real?()
		invariant()
		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real?)
			return false unless @matrix_table[key].real?
		end
		invariant()
	end
	
	def imaginary() 
		invariant()

		resultmatrix = self
		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:imaginary)
			resultmatrix[key] = @matrix_table[key].imaginary
		end

		check_dimensions_are_the_same(resultmatrix)
		invariant()
	end

	def imaginary?()
		invariant()

		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real?)
			return false unless !(@matrix_table[key].real?)
		end
		invariant()
	end


	private

		def invariant()
			if square?
				identitymatrix = SparseMatrix.identity(@num_rows)
				raise "Matrix does not satisfy A * A.getInverse() = I invariant" unless multiplication(self.getInverse()) == identitymatrix

				raise "Matrix does not satisfy A.getDeterminant() == 0 when I.getInverse() == null invariant" unless self.getDeterminant() == 0 && self.getInverse() == nil
			end

			raise "Matrix does not satisfy A*I = A invariant" unless multiplication(SparseMatrix.identity(@num_columns)) == self

			raise "Matrix does not satisfy A+A = 2A" unless addition(self) == multiplication(2)
			raise "Matrix does not satisfy A-A = 0" unless subtraction(self) == SparseMatrix.new(Hash.new(0))

			raise "Matrix must satisfy that itself is not null" unless !(@matrix_table.nil? && @matrix_table.values.any?{|val| val.nil? })
		end

		def square? 
			@num_rows == @num_columns
		end

		def check_matching_dimensions(othermatrix)
			begin
				raise "Cannot perform operation, deminsions do not match." unless @num_rows == othermatrix.num_rows && @num_columns == othermatrix.num_columns
			end
		end

		def check_dimensions_are_the_same(result)
			begin
				raise "Matrix dimensions must remain the same." unless othermatrix.num_rows == result.num_rows && othermatrix.num_columns == result.num_columns
			end
		end

		def check_compatible_dimensions_for_multiplication(othermatrix) 
			begin
				raise "Cannot perform operation, deminsions are not compatible." unless @num_columns == othermatrix.num_rows
			end
			# {row: @num_rows, column: othermatrix.num_columns}
		end

		def check_correct_dimensions_after_multiplication(othermatrix, result)
			begin
				raise "Multiplication dimensions are incorrect." unless @num_rows == result.num_rows && @num_columns == result.num_columns
			end
		end

		def check_square_matrix()
			begin
				raise "Cannot perform operation, matrix not square." unless @num_columns == @num_rows
			end
		end

		def check_result_is_number(result) 
			begin
				raise "Result is a number" unless result.is_a? Numeric
			end
		end

		def check_correct_dimensions_after_transpose(result, current_dimensions) 
			begin
				raise "Incorrect matrix dimensions." unless current_dimensions[:row] == @num_columns && @num_rows == current_dimensions[:column]
			end
		end 
end

