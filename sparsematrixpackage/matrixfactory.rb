require 'tridagonal_matrix'
require 'sparse_matrix'

module MatrixFactory 

    def self.create(classname, matrixarray)

        case classname
        when :tridiagonal
            puts "hi tri"
            TriagonalMatrix.new(matrixarray)
        when :sparse 
            puts "hi spar"
            SparseMatrix.new(matrixarray)
        end

    end
    
end