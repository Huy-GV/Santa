class A

    attr_accessor :attr_a, :attr_b

    def initialize
        @attr_a = false
        @attr_b = true
    end
end

class B < A

    def initialize
        @x = 0
        super
    end
end

b = B.new
puts b.attr_a
puts b.attr_b