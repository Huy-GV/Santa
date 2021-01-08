class Platform
    attr_accessor :x, :y

    def initialize(x, y)
        @x, @y = x, y
    end
    
    def draw
        Gosu::Image.new("media/platforms/platform.png").draw_rot(@x, @y, ZOrder::PLAYER, 0)
    end

    def update
        @x -= 2
    end

end

class Trap
    attr_accessor :x, :trap_type

    def initialize(x)
        @x = x
        @trap_image = Gosu::Image.load_tiles("media/platforms/metal_spike.png", 234/3, 66)
        @current_image = @trap_image[0]
    end
    
    def draw
        @current_image.draw_rot(@x, 680, ZOrder::TRAP, 0)
    end

    def update
        @x -= 2
    end

    def spike
        @current_image = @trap_image[Gosu::milliseconds / 180 % @trap_image.length]
    end
end