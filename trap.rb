class Trap
    attr_accessor :x, :trap_type, :has_spiked

    def initialize(x)
        @x = x
        @has_spiked = false
        @trap_image = Gosu::Image.load_tiles("media/platforms/metal_spike.png", 234/3, 66)

        @final_image = @trap_image[@trap_image.size - 1]
        @current_image = @trap_image[0]
    end
    
    def draw
        @current_image.draw_rot(@x, 680, ZOrder::TRAP, 0)
    end

    def update
        @x -= 2
        if @has_spiked then @current_image = @final_image end
    end

    def spike
        # @current_image = @trap_image[Gosu::milliseconds / 180 % @trap_image.length]
    end
end