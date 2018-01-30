
require 'matrix'

# inherits from Matrix for utilization of 
class TriDiagonalMatrix
	
	include Enumerable
	
	# let matrix handle these functions
	# extend Forwardable
	# delegate [:**, :hermitian?, :normal?, :permutation?] => to_m

	attr_reader :num_columns, :num_rows

	def self.rows(rows, copy = true)
		
		# rows = convert_to_array(rows, true) 
		# rows.map! { |row| convert_to_array(row, copy) }

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
		new Array.new(n-1) { 0 }, Array.new(n) { value }, Array.new(n-1) { 0 }
	end 
	
	def initialize(upper_diag, middle_diag, lower_diag)
		# invariant()
		# #PRE
		# size_constraint()

		@upper_diagonal = upper_diag
		@middle_diagonal = middle_diag
		@lower_diagonal = lower_diag

		#POST
		diagonal_array_sizes()
		# invariant()
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
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		return_matrix = addition(other_matrix)
		
		#POST
		check_dimensions(return_matrix)
		
		invariant()
	end
	
	def -(other_matrix)
		invariant()

		#PRE
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)
		
		return_matrix = subtraction(other_matrix)
		
		#Post
		check_dimensions(return_matrix)
		
		invariant()
	end
	
	def *(other_matrix)
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)
		
		return_matrix = multiplication(other_matrix)
		#POST
		check_correct_dimensions_after_multiplication(other_matrix, return_matrix)
		
		invariant()
	end
	
	def /(other_matrix)
		invariant()

		#PRE 
		check_tridiagonality(other_matrix)
		check_dimensions(other_matrix)

		return_matrix = division(other_matrix)
		
		#POST
		check_correct_dimensions_after_multiplication(other_matrix, return_matrix)
		
		invariant()
	end


	def determinant
		invariant()

		#PRE - not necessary to check if square, since tridiagonal matrices are square

		determinant_method()

		#POST
		
		invariant()
	end

	def transpose
		invariant()

		#PRE - none as it is guaranteed to be square tridiagonal at this point

		transpose_method()

		#POST

		invariant()
	end 

	def inverse
		invariant()

		#PRE

		inverse_method()

		#POST

		invariant()
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
	
	# all private methods

	def upper_diagonal
		Vector.elements(@upper_diagonal)
	end

	def middle_diagonal
		Vector.elements(@middle_diagonal)
	end

	def lower_diagonal
		Vector.elements(@lower_diagonal)
	end
	
	private 

	attr_writer :upper_diagonal, :middle_diagonal, :lower_diagonal

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

	def size_constraint()
		raise "Improper matrix size given" unless @num_rows > 0
	end 

	def diagonal_array_sizes()
		raise "The diagonal arrays are of improper size" unless @middle_diagonal.size == @upper_diagonal.size+1 && @middle_diagonal.size == @lower_diagonal.size+1
	end

	def check_tridiagonality(other_matrix)
		raise "Other object is not tridiagonal" unless TriDiagonalMatrix === other_matrix
	end

	def check_dimensions(other_matrix)
		raise "Matricies do not have the same dimentions" unless row_count() == other_matrix.row_count()
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

	# def convert_to_array(obj, copy = false) # :nodoc:
 #      case obj
 #      when Array
 #        copy ? obj.dup : obj
 #      when Vector
 #        obj.to_a
 #      else
 #        begin
 #          converted = obj.to_ary
 #        rescue Exception => e
 #          raise TypeError, "can't convert #{obj.class} into an Array (#{e.message})"
 #        end
 #        raise TypeError, "#{obj.class}#to_ary should return an Array" unless converted.is_a? Array
 #        converted
 #      end
 #    end
	
	alias_method :column_count, :row_count
	alias_method :det, :determinant
	# alias_method :inspect, :to_s
	# alias_method :collect, :map
	# alias_method :tr, :trace
	alias_method :t, :transpose

end
