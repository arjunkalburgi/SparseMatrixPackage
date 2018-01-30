
class SparseMatrix

	attr_reader :matrix_table, :num_rows, :num_columns

	def self.identity(size)
		new_sparse = {num_columns: size, num_rows: size, matrix_table: {}}
		(0..size).each do |i|
			new_sparse[:matrix_table][{row: i, column: i}] = 1
		end
	end

	def self.scalar(n, value)
		(0..n).each do |i|
			@matrix_table[{row: i, column: i}] = value
		end
	end 
	
	def initialize(input)
		case input 
			when Array 
				rows(input)
			when Matrix
				rows(input.to_a())
			when Hash
				@matrix_table = input
				# assume the maximum row and col given gives the dimensions (to be changed in proper implementation)
				@num_rows = input.keys.map{|key| key[:row]}.max
				@num_columns = input.keys.map{|key| key[:column]}.max
			else 
				raise "Input must be of type Array (array of arrays), Matrix or Hash."
		end
	end
	
	def +(other_matrix)
		invariant()
		check_matching_dimensions(other_matrix)
		
		result_matrix = addition(other_matrix)

		check_dimensions_are_the_same(result_matrix)
		invariant()

		result_matrix
	end
	
	def -(other_matrix)
		invariant()
		check_matching_dimensions(other_matrix)
		
		result_matrix = subtraction(other_matrix)

		check_dimensions_are_the_same(result_matrix)
		invariant()

		result_matrix
	end
	
	def *(other_matrix)
		invariant()
		check_compatible_dimensions_for_multiplication(other_matrix)
		
		result_matrix = multiplication(other_matrix)

		check_correct_dimensions_after_multiplication(other_matrix, result_matrix)
		invariant()

		result_matrix
	end
	
	def /(other_matrix)
		invariant()
		check_compatible_dimensions_for_multiplication(other_matrix.getInverse())

		result_matrix = multiplication(other_matrix.getInverse())

		check_correct_dimensions_after_multiplication(other_matrix.getInverse())
		invariant()

		result_matrix
	end
	
	def getDeterminant()
		invariant()
		check_square_matrix()
		
		result = getMatrixDeterminant()

		check_result_is_number(result)
		invariant()

		result
	end
	
	def getInverse()
		invariant()
		check_square_matrix()
		
		result_matrix = inverse()

		check_square_matrix()
		invariant()

		result_matrix
	end
	
	def getTranspose()
		invariant()

		result_matrix = transpose()
		
		check_correct_dimensions_after_transpose(result_matrix, {row: @num_rows, column: @num_columns})
		invariant()

		result_matrix
	end
	
	def ==(other_matrix)
		invariant()
		check_matching_dimensions(other_matrix)
		
		result = (@matrix_table == other_matrix.matrix_table)
		
		invariant()

		result
	end

	def real() 
		invariant()

		result_matrix = self
		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real)
			result_matrix[key] = @matrix_table[key].real
		end

		check_dimensions_are_the_same(result_matrix)
		invariant()

		result_matrix
	end

	def real?()
		invariant()

		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real?)
			return false unless @matrix_table[key].real?
		end

		invariant()

		true
	end
	
	def imaginary() 
		invariant()

		result_matrix = self
		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:imaginary)
			result_matrix[key] = @matrix_table[key].imaginary
		end

		check_dimensions_are_the_same(result_matrix)
		invariant()

		result_matrix
	end

	def imaginary?()
		invariant()

		@matrix_table.keys.each do |key|
			raise "Must be of type Numeric to test real" unless @matrix_table[key].respond_to?(:real?)
			return false unless !(@matrix_table[key].real?)
		end

		invariant()

		true 
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

			def addition(other_matrix)
				puts "add"
			end

			def subtraction(other_matrix)
				puts "subtract"
			end

			def multiplication(other_matrix)
				puts "multiply"
			end

			def getMatrixDeterminant()
				puts "determinant"
			end

			def inverse()
				puts "invert"
			end

			def transpose()
				puts "transpose"
			end
		
		# TESTS
			def invariant()
				if square?
					identitymatrix = SparseMatrix.identity(@num_rows)
					raise "Matrix does not satisfy A * A.getInverse() = I invariant" unless multiplication(inverse()) == identitymatrix

					raise "Matrix does not satisfy A.getDeterminant() == 0 when I.getInverse() == null invariant" unless getMatrixDeterminant() == 0 && inverse() == nil
				end

				raise "Matrix does not satisfy A*I = A invariant" unless multiplication(SparseMatrix.identity(@num_columns)) == self

				raise "Matrix does not satisfy A+A = 2A" unless addition(self) == multiplication(2)
				raise "Matrix does not satisfy A-A = 0" unless subtraction(self) == SparseMatrix.new(Hash.new(0))

				raise "Matrix must satisfy that itself is not null" unless !(@matrix_table.nil? && @matrix_table.values.any?{|val| val.nil? })
			end

			def square? 
				@num_rows == @num_columns
			end

			def check_matching_dimensions(other_matrix)
				begin
					raise "Cannot perform operation, deminsions do not match." unless @num_rows == other_matrix.num_rows && @num_columns == other_matrix.num_columns
				end
			end

			def check_dimensions_are_the_same(result)
				puts result
				begin
					raise "Matrix dimensions must remain the same." unless @num_rows == result.num_rows && @num_columns == result.num_columns
				end
			end

			def check_compatible_dimensions_for_multiplication(other_matrix) 
				begin
					raise "Cannot perform operation, deminsions are not compatible." unless @num_columns == other_matrix.num_rows
				end
				# {row: @num_rows, column: other_matrix.num_columns}
			end

			def check_correct_dimensions_after_multiplication(other_matrix, result)
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

