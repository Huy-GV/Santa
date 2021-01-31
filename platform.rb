class Platform
    attr_accessor :x, :y

    def initialize(x, y)
        @x, @y = x, y

    end
    
    def draw
        Gosu::Image.new("media/platforms/platform.png").draw(@x, @y, ZOrder::PLAYER)
    end

    def update
        @x -= 2
    end

end

