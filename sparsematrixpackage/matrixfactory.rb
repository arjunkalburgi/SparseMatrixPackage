require 'tridagonal_matrix'
require 'sparse_matrix'

module MatrixFactory 

    def self.create(classname, matrixarray)
        classname.new(matrixarray)
    end
    
end