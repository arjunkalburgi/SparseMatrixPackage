# definition for the sparse matrix class
require 'matrix'

class SparseMatrix

	attr_reader :matrix_structure

	def initialize()
		#Pre 

		@matrix_structure = Hash.new
		create(rowcount, colcount)
		
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

