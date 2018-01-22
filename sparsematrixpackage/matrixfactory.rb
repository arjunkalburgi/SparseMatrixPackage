require 'tridagonal_matrix'
require 'sparse_matrix'

module MatrixFactory 

    def self.create(classname, matrixarray)
        #pre 
        is_array(matrixarray)

        classname.new(matrixarray)
    end
    
end