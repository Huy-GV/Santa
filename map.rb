class Map

    def initialize
        @bg = Gosu::Image.new("media/backgrounds/bg_color.png")
        @far1 = @far2 = Gosu::Image.new("media/backgrounds/far.png")
        @mid1 = @mid2 = Gosu::Image.new("media/backgrounds/mid.png")
        @ground1 = @ground2 = Gosu::Image.new("media/backgrounds/ground.png")
        @close1 = @close2 = Gosu::Image.new("media/backgrounds/close.png")
        @far_x1 = @mid_x1 = @close_x1 = @ground_x1 = WIDTH / 2
        @far_x2 = @mid_x2 = @close_x2 = WIDTH / 2 + FULL_BACKGROUND_WIDTH * 1.8
        @ground_x2 = WIDTH / 2 + 2970
    end

    def draw
        @bg.draw_rot(WIDTH / 2, 400, ZOrder::BACKGROUND1, 0)

        @far1.draw_rot(@far_x1, HEIGHT / 2, ZOrder::BACKGROUND2, 0)
        @mid1.draw_rot(@mid_x1, HEIGHT / 2, ZOrder::BACKGROUND3, 0)
        @close1.draw_rot(@close_x1, HEIGHT / 2, ZOrder::BACKGROUND4, 0)

        @far2.draw_rot(@far_x2, HEIGHT / 2, ZOrder::BACKGROUND2, 0)
        @mid2.draw_rot(@mid_x2, HEIGHT / 2, ZOrder::BACKGROUND3, 0)
        @close2.draw_rot(@close_x2, HEIGHT / 2, ZOrder::BACKGROUND4, 0)

        @ground1.draw_rot(@ground_x1, 755, ZOrder::GROUND,0 )
        @ground2.draw_rot(@ground_x2, 755, ZOrder::GROUND,0 )
    end
    
    def roll
        
        if @far_x1 < -FULL_BACKGROUND_WIDTH
            @far_x1 = FULL_BACKGROUND_WIDTH * 1.8
        else
            @far_x1 -= 1
        end

        if @far_x2 < -FULL_BACKGROUND_WIDTH
            @far_x2 = FULL_BACKGROUND_WIDTH * 1.8 
        else
            @far_x2 -= 1
        end

        if @mid_x1 < -FULL_BACKGROUND_WIDTH
            @mid_x1 = FULL_BACKGROUND_WIDTH * 1.8
        else
            @mid_x1 -= 1.5
        end

        if @mid_x2 < -FULL_BACKGROUND_WIDTH
            @mid_x2 = FULL_BACKGROUND_WIDTH * 1.8 
        else
            @mid_x2 -= 1.5
        end

        if @close_x1 < -FULL_BACKGROUND_WIDTH
            @close_x1 = FULL_BACKGROUND_WIDTH * 1.8 
        else
            @close_x1 -= 2
        end

        if @close_x2 < -FULL_BACKGROUND_WIDTH
            @close_x2 = FULL_BACKGROUND_WIDTH * 1.8
        else
            @close_x2 -= 2
        end

        if @ground_x1 <= -2970/2
            @ground_x1 = 2970 * 1.5
        else
            @ground_x1 -= 2
        end

        if @ground_x2 <= -2970/2
            @ground_x2 = 2970 * 1.5
        else
            @ground_x2 -= 2
        end

    end
end