# :)
require 'matrix'

# inherits from Matrix for utilization of 
class TriDiagonalMatrix < Matrix
	
	# let matrix handle these functions
	# delegate [:+, :**, :-, :hermitian?, :normal?, :permutation?] => :Matrix.send(:new, to_a)
	
	# all public methods...
	 
	def initialize(rows)
		#PRE
		#ensure nxn
		#ensure there are 3 diagonals of proper sizes
		
		rows = convert_to_array(row, true) # not sure if true is needed to copy object
		
		@size = (rows[0] || []).size 
		
		@top_diag = top
		@middle_diag = middle
		@bottom_diag = bottom
		
		#POST
	end
	
	# all private methods...
	
	private 
	
end
