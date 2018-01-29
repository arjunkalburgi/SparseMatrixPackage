# definition for the sparse matrix class
require 'matrix'

class SparseMatrix

	attr_reader :matrix_table, :num_rows, :num_columns

	def initialize(matrixarray)
		#Pre 

		@num_rows = matrixarray.size
		@num_columns = matrixarray[0].size

		@matrix_table = Hash.new(0)
		matrixarray.each_index do |i|
			# raise "Not all columns are the same size." unless matrixarray[i].size != @num_columns 
			matrixarray[i].each_index do |j|
				if matrixarray[i][j] != 0
					@matrix_table[{row: i, col: j}] = matrixarray[i][j] 
				end
			end
		end

		# GET THE INDEXES 
		### @matrix_table.keys.each do |i|
		### 	puts i[:row], i[:col]
		### end
		
		#Post
		
	end
	
	def +(othermatrix)
		begin
			raise "Cannot perform operation, deminsions do not match." unless @num_rows == othermatrix.num_rows && @num_columns == othermatrix.num_columns
		end


		matrix = othermatrix.matrix_table
		
		all_keys_with_value = @matrix_table.keys + matrix.keys

		all_keys_with_value.each do |key| 
			@matrix_table[key] += matrix[key]
		end

		
		begin
			raise "Matrix dimensions must remain the same." unless othermatrix.num_rows == (self+matrix).num_rows && othermatrix.num_columns == (self+matrix).num_columns
		end
	end
	
	def -(othermatrix)
		begin
			raise "Cannot perform operation, deminsions do not match." unless @num_rows == othermatrix.num_rows && @num_columns == othermatrix.num_columns
		end
		

		matrix = othermatrix.matrix_table
		all_keys_with_value = @matrix_table.keys + matrix.keys

		all_keys_with_value.each do |key| 
			@matrix_table[key] -= matrix[key]
		end


		begin
			raise "Matrix dimensions must remain the same." unless othermatrix.num_rows == (self-matrix).num_rows && othermatrix.num_columns == (self-matrix).num_columns
		end
	end
	
	def *(othermatrix)
		begin
			raise "Cannot perform operation, deminsions are not compatible." unless @num_columns == othermatrix.num_rows
			original_rows = @num_rows
			orignal2_columns = othermatrix.num_columns
		end
		

		begin
			raise "Multiplication dimensions are incorrect." unless original_rows == (self*matrix).num_rows && orignal2_columns == (self*matrix).num_columns
		end
	end
	
	def /(othermatrix)
		begin
			raise "Cannot perform operation, deminsions are not compatible." unless @num_columns == matrix.getInverse().num_rows
			original_rows = @num_rows
			orignal2_columns = matrix.getInverse().num_columns
		end

		self * matrix.getInverse()
		
		begin
			raise "Multiplication dimensions are incorrect." unless original_rows == (self/matrix).num_rows && orignal2_columns == (self/matrix).num_columns
		end
	end
	
	def getDeterminant()
		begin
			raise "Cannot perform operation, dimensions are not compatible." unless @num_columns == @num_rows
		end
		
		begin
			raise "Determinant is a number" unless self.getDeterminant().is_a? Numeric
		end
	end
	
	def getInverse()
		begin
			raise "Matrix dimensions must be the same." unless @num_rows == @num_columns
		end
		
		begin
			raise "Matrix dimensions must remain the same." unless @num_rows == @num_columns
			# raise "Inverse Matrix must obey A*A.inv = I property" unless (A * A.getInverse()) == 
		end
	end
	
	def getTranspose()
		begin
			# raise "Cannot perform operation, deminsions are not compatible." unless @num_columns == @num_rows
			original2_rows = @num_rows
			orignal2_columns = @num_columns
		end
		
		begin
			raise "Incorrect matrix dimensions." unless @original2_rows == @num_columns && @num_rows == @orignal2_columns
		end
	end
	
	def ==(othermatrix)
		begin
			raise "Cannot perform operation, deminsions do not match." unless @num_rows == othermatrix.num_rows && @num_columns == othermatrix.num_columns	
		end
		
		@matrix_table == othermatrix.matrix_table
		
		begin
		end
	end
	
end

