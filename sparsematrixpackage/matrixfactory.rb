require_relative './tridiagonal_matrix'
require_relative './sparse_matrix'

module MatrixFactory 
    def self.create(classname, *args)
		if args.size == 1
			classname.new(args[0])
		else
			classname.new(*args)
		end
    end
end
