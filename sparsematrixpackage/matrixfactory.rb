require_relative './tridagonal_matrix'
require_relative './sparse_matrix'

module MatrixFactory 

    def self.create(classname, matrixarray)
        begin
            raise "Matrix input must be an array of arrays" unless matrixarray.is_a? Array
        end

        classname.rows(matrixarray)
    end
    
end
