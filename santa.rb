
class Santa
    attr_accessor :y, :is_dying, :is_alive, :health, :stamina, :on_platform, :status

    def initialize(x, y)
        @x, @y= x, y
        @vx = @vy = 0
        load_images
        @is_dying = false
        @@on_solid = @is_alive = true
        @health = @stamina = 100
        @status = 'running'
    end

    def load_images
        @run_image = Gosu::Image.load_tiles("media/santa/santa_run.png", 2741/11, 171)
        @slide_image = Gosu::Image.load_tiles("media/santa/santa_slide.png", 2741/11, 171)
        @jump_image = Gosu::Image.load_tiles("media/santa/santa_jump.png", 3987/16, 171)
        @die_image = Gosu::Image.load_tiles('media/santa/santa_die.png', 4236/17, 171)   
    end

    def draw
        @current_image.draw_rot(@x, @y, ZOrder::PLAYER,0)
    end

    def lose_health(damage)
        @health -= damage
    end



    def update
        # TODO break this into multiple methods
        if @current_image == @die_image[@die_image.size - 1] then @is_alive = false end
        control_jump_aniamtion
        control_slide_animation
        update_status
        control_energy
        gain_energy
    end

    def run_on_platform
        @on_platform = true
    end

    def run_on_ground
        @on_platform = false
    end

    def gain_energy
        @health += 0.7 / 60.to_f unless @health >= 100
        @stamina += 2.5 / 60.to_f unless @stamina >= 100
    end

    def control_energy
        if @stamina < 0 then @stamina = 0 end
        if @health < 0 then @health = 0 end
        if @stamina >=100 then @stamina = 100 end
        if @health >= 100 then @health = 100 end
    end

    def control_jump_aniamtion
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
    end

    def control_slide_animation
        @vx += 1 if @vx < 0
    end

    def update_status
        if @vx < 0
            @status = 'sliding'
        elsif @y < GROUND and !@on_platform
            @status = 'jumping'
        else
            @status = 'running'
        end
    end

    def jump_allowed?(stamina_cost)
        if ((@y == GROUND) || @on_platform) &&
            (@stamina >= stamina_cost) &&
            !@is_sliding &&
            !@is_jumping
            true
        else
            false
        end
    end

    def slide_allowed?(stamina_cost)
        if (@y == GROUND) &&
            (@stamina >= stamina_cost) &&
            !@is_jumping &&
            !@is_sliding
            true
        else
            false
        end
    end

    def set_up_slide(stamina_cost)
        @vx = -25
        @stamina -= stamina_cost
        @slide_offset = Gosu.milliseconds
    end

    def set_up_jump(stamina_cost)
        @vy = -25
        @stamina -= stamina_cost
        @jump_offset = Gosu.milliseconds
    end

    def start_die_animation
        @die_offset = Gosu.milliseconds
        @is_dying = true
    end

    def run_forward
        @current_image = @run_image[Gosu.milliseconds / 40 % 11]
    end

    def jump
        @current_image = @jump_image[(Gosu.milliseconds - @jump_offset)/ 45 % 16]
    end

    def slide
        @current_image = @slide_image[(Gosu.milliseconds - @slide_offset) / 45 % 11]
    end

    def die
        @is_dying = true
        @current_image = @die_image[(Gosu.milliseconds - @die_offset) / 110 % 17]
    end
end