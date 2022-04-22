class Trap
    attr_accessor :x

    def initialize(x)
        @x = x
        @trap_image = Gosu::Image.load_tiles("../media/platforms/metal_spike.png", 234/3, 66)

        @final_image = @trap_image[@trap_image.size - 1]
        @current_image = @trap_image[0]
    end
    
    def draw
        @current_image.draw_rot(@x, 680, ZOrder::TRAP, 0)
    end

    # trap will spike from the start
    def update
        @x -= SCREEN_ROLL_SPEED
    end
end