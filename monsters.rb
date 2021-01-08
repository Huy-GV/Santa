class Monster
    attr_accessor :x, :y, :type, :action, :original_action, :is_alive, :is_hit, :die_offset
    #generate 2 random numbers and return the corresponding types and actions
    def initialize(x, y, type, action) 
        @x, @y, @type, @action = x, y, type, action
        @original_action = action
        @die_offset = 0
        @is_alive = true
        @is_hit = false
        case @type  
        when "DRAGON"
            @idle_image = Gosu::Image.load_tiles("media/monsters/dragon_idle.png",964/3,320)
            @move_image = Gosu::Image.load_tiles("media/monsters/dragon_moving.png",1606/5,320)
            @attack_image = Gosu::Image.load_tiles("media/monsters/dragon_attack.png",1288/4,322)
            @dying_image = Gosu::Image.load_tiles("media/monsters/dragon_dying.png",2880/9,320)
            @current_image = @idle_image[0]
        when "MEDUSA"
            @idle_image = Gosu::Image.load_tiles("media/monsters/medusa_idle.png",765/3,255)
            @move_image = Gosu::Image.load_tiles("media/monsters/medusa_moving.png",1020/4,255)
            @attack_image = Gosu::Image.load_tiles("media/monsters/medusa_attack.png",1530/6,254)
            @dying_image = Gosu::Image.load_tiles("media/monsters/medusa_dying.png",2540/10,254)
            @current_image = @idle_image[0]
        when "DEMON"
            @idle_image = Gosu::Image.load_tiles("media/monsters/demon_idle.png",963/3,320)
            @move_image = Gosu::Image.load_tiles("media/monsters/demon_moving.png",1926/6,320)
            @attack_image = Gosu::Image.load_tiles("media/monsters/demon_attack.png",1288/4,322)
            @dying_image = Gosu::Image.load_tiles("media/monsters/demon_dying.png",3200/10,320)
            @current_image = @idle_image[0]
        when 'FLY'
            @move_image = Gosu::Image.load_tiles("media/monsters/fly.png",1200/6,200)
            @current_image = @move_image[0]
            @dying_image = Gosu::Image.load_tiles("media/monsters/demon_dying.png",3200/10,320)

        end
        
        @last_dying_image =  @dying_image[@dying_image.size - 1]
    end

    def draw

        @current_image.draw_rot(@x, @y, ZOrder::PLAYER, 0)
    end

    def update
        @current_image == @last_dying_image ? @is_alive = false : @is_alive = true
    end

    def idle
        @current_image = @idle_image[Gosu.milliseconds / 230 % 3]
        @x -= 2
    end

    def move
        case @type
        when 'MEDUSA'
            @current_image = @move_image[Gosu.milliseconds / 110 % 4]
        when 'DEMON'
            @current_image = @move_image[Gosu.milliseconds / 110 % 6]
        when 'DRAGON'
            @current_image = @move_image[Gosu.milliseconds / 110 % 5]
        when 'FLY'
            @current_image = @move_image[Gosu.milliseconds / 110 % 6]
        end
        @x -= 5
    end

    def attack
        case @type
        when 'MEDUSA'
            @current_image = @attack_image[Gosu.milliseconds / 140 % 6]
        when 'DEMON'
            @current_image = @attack_image[Gosu.milliseconds / 140 % 4]
        when 'DRAGON'
            @current_image = @attack_image[Gosu.milliseconds / 140 % 4]
        end
        @x -= 2
    end

    def die(die_offset)
        @current_image = @dying_image[(Gosu.milliseconds - die_offset) / 230 % (@dying_image.size)]
        @x -= 2
    end

end

class Flying_Goblin < Monster
    def update
        @x -= 3
    end
end
