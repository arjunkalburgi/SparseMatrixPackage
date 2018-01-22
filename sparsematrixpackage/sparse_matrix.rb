# definition for the sparse matrix class
require 'matrix'
require 'enumerator'

class SparseMatrix

	attr_reader :matrix_structure

	def initialize(matrixarray)
		#Pre 

		@num_rows = matrixarray.size
		@num_columns = matrixarray[0].size

		@matrix_structure = Hash.new(0)
		matrixarray.each_index do |i|
			matrixarray[i].each_index do |j|
				if matrixarray[i][j] != 0
					@matrix_structure[{row: i, col: j}] = matrixarray[i][j] 
				end
			end
		end

		# GET THE INDEXES 
		### @matrix_structure.keys.each do |i|
		### 	puts i[:row], i[:col]
		### end
		
		#Post
		
	end

	def create(rowcount, colcount)

	end
	
	
	def +(matrix)
		#Pre 
		
		#Post
		# this sparse matrix has had the contents of give matrix added to it
	end
	
	def -(matrix)
		#Pre 
			begin
				
			end
		
		#Post
		# this sparse matrix has had the contents of given matrix subtracted from it
	end
	
	def *(matrix)
		#Pre 
		
		#Post
		# this sparse matrix has been multiplied by given matrix 
	end
	
	def /(matrix)
		#Pre 
		
		#Post
		# this sparse matrix has been divided by given matrix
	end
	
	def exponent(matrix)
		#Pre 
		
		#Post
		# this sparse matrix has been set to the exponent of given matrix (???)
	end
	
	def getDeterminant()
		#Pre 
		
		#Post
		# none, determinant is returned
	end
	
	def getInverse()
		#Pre 
		
		#Post
		# matrix is set to its own inverse
	end
	
	def getTranspose()
		#Pre 
		
		#Post
		# matrix is set to its own transpose
	end
	
	
end

