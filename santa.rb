class Santa
    attr_accessor :x, :y, :vy, :vx, :is_jumping, :is_sliding, :is_dying, :is_alive, :health, :stamina, :can_jump, :on_platform, :slide_cooldown

    def initialize(x,y)
        @x, @y= x, y
        @vx = @vy = 0

        @idle_image = Gosu::Image.load_tiles("media/santa/santa_idle.png", 997/4, 171)
        @move_image = Gosu::Image.load_tiles("media/santa/santa_run.png", 2741/11, 171)
        @slide_image = Gosu::Image.load_tiles("media/santa/santa_slide.png", 2741/11, 171)
        @jump_image = Gosu::Image.load_tiles("media/santa/santa_jump.png", 3987/16, 171)
        @die_image = Gosu::Image.load_tiles("media/santa/santa_die.png", 4236/17, 171)

        @is_jumping = @is_sliding = @is_dying = false
        @can_jump = @on_solid = @is_alive = true
        @health = @stamina = @slide_cooldown = @difficulty = 3
        
    end

    def draw
        @current_image.draw_rot(@x, @y, ZOrder::PLAYER,0)
    end

    def update

            if @current_image == @die_image[@die_image.size - 1]
                @is_alive = false
            end

            @stamina += 0.08 / 60 unless @stamina >= @difficulty
            @slide_cooldown += 0.9 / 40 unless @slide_cooldown >= @difficulty

            if @stamina < 0 then @stamina = 0 end
            if @health < 0 then @health = 0 end
            if @slide_cooldown < 0 then @slide_cooldown = 0 end

            if @stamina >= @difficulty then @stamina = @difficulty end
            if @health >= @difficulty then @health = @difficulty end
            if @slide_cooldown >= @difficulty then @slide_cooldown = @difficulty end

            if @y < GROUND and !@on_platform 
                @is_jumping = true 
            else
                @is_jumping = false 
            end

            @vy += 1

            if @vy > 0
                @vy.times {
                    if @y < GROUND and !@on_platform
                        @y += 1
                    else
                        @vy = 0
                    end
                }
            end

            if @vy < 0
                (-@vy).times { 
                    @y -= 1
                }
            end

            @vx < 0 ? @is_sliding = true : @is_sliding = false
            @vx += 1 if @vx < 0

    end

    def run_forward
        if @x < WIDTH then @x += 4 end
        @current_image = @move_image[Gosu.milliseconds / 35 % 11]
    end

    def run_backward
        if @x > -2 then @x -= 6 end
        @current_image = @move_image[Gosu.milliseconds / 35 % 11] 
    end

    def jump(jump_offset)
        @current_image = @jump_image[(Gosu.milliseconds - jump_offset)/ 45 % 16]
    end

    def slide(slide_offset)
        @current_image = @slide_image[(Gosu.milliseconds - slide_offset) / 45 % 11]
        @x += 4
    end
    
    def idle
        if @x > -2 then @x -= 2 end
        @current_image = @idle_image[Gosu.milliseconds / 85 % 4]
    end

    def die(die_offset)
        @is_dying = true
        @current_image = @die_image[(Gosu.milliseconds - die_offset) / 110 % 17]
    end

end