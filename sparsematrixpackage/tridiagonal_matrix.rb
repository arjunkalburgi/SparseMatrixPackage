
class TriDiagonalMatrix
	
	include Enumerable
	
	attr_reader :num_columns, :num_rows, :upper_diagonal, :middle_diagonal, :lower_diagonal
	
	def initialize(input)
		# invariant()
		#PRE
		
		case input
			when Array
				rows(input)
			when Matrix
				rows(input.to_a())
			else 
				raise "Must input Array or Matrix"
		end

		#POST
		diagonal_array_sizes()
		# invariant()
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
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		return_result_matrix = addition(other_matrix)
		
		#POST
		check_dimensions(return_result_matrix)
		
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
	
	def *(other_matrix)
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)
		
		return_result_matrix = multiplication(other_matrix)
		#POST
		check_correct_dimensions_after_multiplication(other_matrix, return_result_matrix)
		
		invariant()

		return_result_matrix
	end
	
	def /(other_matrix)
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		return_result_matrix = division(other_matrix)
		
		#POST
		check_correct_dimensions_after_multiplication(other_matrix, return_result_matrix)
		
		invariant()

		return_result_matrix
	end


	def determinant
		invariant()

		#PRE - not necessary to check if square, since tridiagonal matrices are square

		return_determinant = determinant_method()

		#POST
		
		invariant()

		return_determinant
	end

	def transpose
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		return_result_matrix = transpose_method()

		#POST

		invariant()

		return_result_matrix
	end 

	def inverse
		invariant()

		#PRE

		return_result_matrix = inverse_method()

		#POST

		invariant()

		return_result_matrix
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
		@num_rows
	end

	def to_a
		Array.new(row_count) { |i|	row(i).to_a }
	end

	def to_s
		"#{self.class.name}#{to_a}"
	end
	
	def to_m
		:Matrix.send(:new, to_a)
	end

	def row(i)
		# return self unless i < row_count
		# row = Array.new(row_count) { |j| self[i, j] }
		# row.each(&Proc.new) if block_given?
		# Vector.elements(row, false)
	end

	def map
		# return to_enum :map unless block_given?
		# block = Proc.new
		# TridiagonalMatrix.send(:new, @upper_diagonal.map(&block), @middle_diagonal.map(&block), @lower_diagonal.map(&block))
	end
	
# 	def transpose!
# 		@upper_diagonal, @lower_diagonal = @lower_diagonal, @upper_diagonal
# 		self
# 	end

# 	def diagonal?
# 		@upper_diagonal.all? { |x| x == 0 } && @lower_diagonal.all? { |x| x == 0 }
# 	end

# 	def toeplitz?
# 		@upper_diagonal.reduce(true) { |a, e| a && e == @upper_diagonal[0] }
# 	end

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

		def identity(size)
			scalar(size, 1)
		end

		def scalar(n, value)
			@upper_diagonal = Array.new(n-1) { 0 }
			@middle_diagonal = Array.new(n) { value }
			@lower_diagonal = Array.new(n-1) { 0 }
		end 

		def invariant()
			# identitymatrix = TriDiagonalMatrix.identity(@num_rows)
			# raise "Matrix does not satisfy A * A.inverse() = I invariant" unless multiplication(self.inverse_method()) == identitymatrix

			# raise "Matrix does not satisfy A.determinant() == 0 when I.inverse() == null invariant" unless self.determinant_method() == 0 && self.inverse_method() == nil
			
			# identitymatrixCol = TriDiagonalMatrix.identity(@num_columns)
			# raise "Matrix does not satisfy A*I = A invariant" unless multiplication(identitymatrixCol) == self

			# raise "Matrix does not satisfy A+A = 2A" unless addition(self) == multiplication(2)

			# subMatrix = subtraction(self)
			# raise "Matrix does not satisfy A-A = 0" unless subMatrix.upper_diagonal.all? {|val| val == 0 } && subMatrix.middle_diagonal.all? {|val| val == 0 } && subMatrix.lower_diagonal.all? {|val| val == 0 }

			# raise "Matrix must satisfy that itself is not null" unless !(@upper_diagonal.any?{|val| val.nil? } && @middle_diagonal.any?{|val| val.nil? } && @lower_diagonal.any?{|val| val.nil? })
		end

		def diagonal_array_sizes()
			raise "The diagonal arrays are of improper size" unless @middle_diagonal.size == @upper_diagonal.size+1 && @middle_diagonal.size == @lower_diagonal.size+1
		end

		def check_tridiagonality(other_matrix)
			raise "Other object is not tridiagonal" unless TriDiagonalMatrix === other_matrix
		end

		def check_dimensions(other_matrix)
			raise "Matricies do not have the same dimensions" unless @num_rows == other_matrix.num_rows
		end

		def check_correct_dimensions_after_multiplication(othermatrix, result)
			raise "Multiplication dimensions are incorrect." unless @num_rows == result.num_rows && @num_columns == result.num_columns
		end

		def addition(other_matrix)
			
		end

		def subtraction(other_matrix)
			
		end 

		def division(other_matrix)
			
		end

		def multiplication(other_matrix)
			
		end

		def determinant_method()

		end

		def transpose_method()
			
		end 

		def inverse_method()

		end

	alias_method :column_count, :row_count
	alias_method :det, :determinant
	alias_method :t, :transpose

end
