require 'rubygems'
require 'gosu'
require './map.rb'
require './santa.rb'
require './interface.rb'
require './monsters.rb'
require './platform.rb'
require './trap.rb'

#CHANGES COMPARED TO VERSION 1: Santa'x coordinate is fixed to improve performance (moderately) and a tutorial option is added

HEIGHT = 800
WIDTH = 1200
FULL_BACKGROUND_WIDTH = 1741
GROUND = 630

MAX_TRAP_AMOUNT = 2
MAX_MONSTER_AMOUNT = 4
MAX_PLATFORM_AMOUNT = 3

module ZOrder
  BACKGROUND1, BACKGROUND2, BACKGROUND3, BACKGROUND4, TRAP, GROUND, PLAYER, UI = *1..8
end

Monster_Action = ['IDLE', 'MOVING']
Monster_Type = ['DRAGON', 'MEDUSA', 'DEMON']
Aerial_Monster = ['FLY']


class SantaGame < Gosu::Window

    def initialize
        super WIDTH, HEIGHT
        self.caption = "Game"
 
        @audio = Gosu::Song.new("media/soundtrack.mp3")
        @difficulty = 3

        @stamina_cost = 0.5
        @score_gain = 1 / 60.to_f

        case @difficulty
        when 3
            @monster_frequency = 250
            @fly_frequency = 300
            @monster_damage = 1.3 / 60.to_f
            @aerial_monster_damage = 0.02
            @platform_frequency = 200
        when 2
            @monster_frequency = 230
            @fly_frequency = 270
            @monster_damage = 1.5 / 60.to_f
            @aerial_monster_damage = 0.03
            @platform_frequency = 220
        when 1
            @monster_frequency = 200
            @fly_frequency = 250
            @monster_damage = 1.7 / 60.to_f
            @aerial_monster_damage = 0.04
            @platform_frequency = 240
        end

        @santa = Santa.new(400, GROUND, @difficulty)
        @map = Map.new
        @interface = Interface.new(@difficulty)

        @monster_horde = Array.new
        @aerial_monster_horde = Array.new
        @platform_set = Array.new
        @trap_set = Array.new
        @scene = :menu

        @pause_message = 'GAME PAUSED'
        @prompt = 'RESUME'

        record_file = File.open("highscore.txt", "r")
        @high_score = record_file.gets.to_i
        record_file.close
    end

    def draw
        case @scene
        when :menu
            @interface.draw_menu_options(@difficulty, @high_score)
        when :tutorial
            @interface.draw_tutorial 
        when :paused
            @interface.draw_pause_options(@pause_message, @prompt)
            @santa.draw if @santa.is_alive
            @map.draw
        when :playing
            @interface.draw_score
            @interface.draw_player_status(@santa.health, @santa.stamina, @santa.slide_cooldown)
            @santa.draw
            @map.draw

            unless @monster_horde.size == 0
                @monster_horde.each {|monster|
                    monster.draw
                }
            end

            unless @aerial_monster_horde.size == 0
                @aerial_monster_horde.each{|fly|
                    fly.draw
                }
            end

            unless @platform_set.size == 0
                @platform_set.each {|platform|
                    platform.draw
                }
            end

            unless@trap_set.size == 0
                @trap_set.each {|spike|
                    spike.draw
                }
            end
        end
    end

    def in_monster_range?(monster_x, player_y)
        monster_x.between?(390, 460) and player_y == GROUND ? true : false
    end

    def in_fly_range?(fly_x, player_y)
        fly_x.between?(360, 440) and player_y.between?(-360, 440) ? true : false
    end

    def in_santa_range?(monster_x, player_y)
        monster_x.between?(390, 480)and player_y == GROUND ? true : false
    end

    def in_trap_range?(player_y, trap_x)
        trap_x.between?(390, 410) and player_y == GROUND ? true : false
    end

    def in_platform_range?(player_y, platform_x)
        platform_x.between?(290, 510) and player_y.between?(415,421) ? true : false
    end

    def needs_cursor?; true; end

    def update

        case @scene
        when :menu
            @audio.pause
            @stamina_cost = 0.5
            @score_gain = 1 / 60.to_f

            case @difficulty
            when 3
                @monster_frequency = 250
                @fly_frequency = 300
                @monster_damage = 1.3 / 60.to_f
                @aerial_monster_damage = 0.02
                @platform_frequency = 200
            when 2
                @monster_frequency = 230
                @fly_frequency = 270
                @monster_damage = 1.5 / 60.to_f
                @aerial_monster_damage = 0.03
                @platform_frequency = 220
            when 1
                @monster_frequency = 200
                @fly_frequency = 250
                @monster_damage = 1.7 / 60.to_f
                @aerial_monster_damage = 0.04
                @platform_frequency = 240
            end
        when :paused

            @audio.play(false)
            @santa.update
            if @santa.is_dying then @santa.die(@die_offset) end
        when :playing

            if ((@santa.y == GROUND or @santa.on_platform) and
                @santa.stamina >= @stamina_cost and 
                !@santa.is_sliding and 
                !@santa.is_jumping)
    
                @santa.can_jump = true
            else
                @santa.can_jump = false
            end

            @audio.play(false)
            @map.roll
            @santa.update
            @interface.update(@score_gain)

            if @santa.health <= 0
                @santa.is_dying = true
                @prompt = 'PLAY AGAIN'
                @die_offset = Gosu.milliseconds
                @pause_message = 'GAME OVER'
                @scene = :paused
            end

            unless @monster_horde.size == 0
                @monster_horde.each { |monster|
                    monster.update
                    case monster.action
                    when 'IDLE'
                        monster.idle
                    when 'MOVING'
                        monster.move
                    when 'ATTACKING'
                        monster.attack
                    when 'DYING'
                        monster.die(monster.die_offset)
                    end

                    #player has a longer attack range than monsters
                    if (in_monster_range?(monster.x, @santa.y) and 
                        monster.action != 'DYING' and
                        !@santa.is_sliding)

                        monster.action = 'ATTACKING'
                        @santa.health -= @monster_damage 
                    elsif (in_santa_range?(monster.x, @santa.y) and 
                        monster.action != 'DYING' and
                        @santa.is_sliding)

                            monster.die_offset = Gosu.milliseconds
                            monster.action = 'DYING'
                            monster.is_hit = true
                    elsif !monster.is_hit
                        monster.action = monster.original_action
                    end

                }
                @monster_horde.reject! { |monster| monster.x < 0 or (!monster.is_alive) }

            end

            unless @aerial_monster_horde.size == 0
                @aerial_monster_horde.each {|fly|
                    fly.update
                    fly.move
                    if in_fly_range?(fly.x, @santa.y)
                        @santa.stamina >= 0.5 ? @santa.stamina -= @stamina_cost : @santa.stamina = 0
                    end
                }
                @aerial_monster_horde.reject!{|fly| fly.x < -30 }
            end

            unless @platform_set.size == 0
                @platform_set.each { |platform| platform.update }
                @platform_set.reject! {|platform| platform.x < -110 }
                @santa.on_platform = in_platform_range?(@santa.y, @platform_set[0].x)
            end

            unless @trap_set.size == 0
                @trap_set.reject! {|trap| trap.x < -40 }

                @trap_set.each {|trap|
                    trap.update
                    if (trap.x < 620) then trap.has_spiked = true end
                    if in_trap_range?(@santa.y, trap.x) then @santa.health -= 0.9 / 40 end
                }
            end

            if rand(@monster_frequency) == 0 and @monster_horde.size < MAX_MONSTER_AMOUNT
                monster_type = Monster_Type[rand(0..(Monster_Type.size - 1))]
                monster_action = Monster_Action[rand(0..(Monster_Action.size - 1))]
                monster_height = GROUND
                if @monster_horde.size == 0
                    monster_x = 1350
                elsif @monster_horde[@monster_horde.size - 1].x > WIDTH
                    monster_x = @monster_horde[@monster_horde.size - 1].x + 150
                else
                    monster_x = 1350
                end

                @monster_horde << Monster.new(monster_x, monster_height, monster_type, monster_action)
            end

            if rand(@fly_frequency) == 0 and @aerial_monster_horde.size < MAX_MONSTER_AMOUNT
                aerial_monster_type = Aerial_Monster[rand(0..(Aerial_Monster.size - 1))]
                if @aerial_monster_horde.size == 0
                    fly_x = 1250
                else
                    last_fly = @aerial_monster_horde[@aerial_monster_horde.size - 1]
                    last_fly.x < 700 ? fly_x = 1300 : fly_x = last_fly.x + 600
                end

                @aerial_monster_horde << Flying_Goblin.new(fly_x, 400, aerial_monster_type, 'MOVING')
            end

            if rand(@platform_frequency) == 0 and @platform_set.size < MAX_PLATFORM_AMOUNT
                if @platform_set.size == 0
                    platform_x = 1500
                else
                    last_platform = @platform_set[@platform_set.size - 1]
                    last_platform.x < 700 ? platform_x = 1500 : platform_x = last_platform.x + 800
                end

                @platform_set << Platform.new(platform_x, 500)
            end

            if rand(@trap_frequency) == 0 and @trap_set.size < MAX_TRAP_AMOUNT
                if @trap_set.size == 0 
                    trap_x = 1300
                else
                    last_trap = @trap_set[@trap_set.size - 1]
                    last_trap.x < 700 ? trap_x = 1300 : trap_x = last_trap.x + 600
                end

                @trap_set << Trap.new(trap_x)
            end

            if !(@santa.is_jumping or @santa.is_sliding)
                @santa.run_forward
            elsif @santa.is_jumping
                @santa.is_sliding = false
                @santa.jump(@jump_offset)
            elsif @santa.is_sliding
                @santa.is_jumping = false
                @santa.slide(@slide_offset)
            end
        end
    end

    def update_record(high_score)
        record_file = File.open("highscore.txt", "r")
        record_high_score = record_file.gets.to_i
        if record_high_score < high_score
            new_high_score = high_score.to_s
            record_file = File.open("highscore.txt", "w")
            record_file.write(new_high_score)
            record_file.close
            return high_score
        end

        return record_high_score
    end

    def reset_game
        @monster_horde.clear
        @platform_set.clear
        @trap_set.clear
        @interface.score = 0
        @difficulty = 3
        @santa = Santa.new(400, GROUND, @difficulty)
        @map = Map.new
    end
        
    def button_down(id)
        case id
        when Gosu::KB_W
            if @santa.can_jump
                @santa.vy = -25
                @jump_offset = Gosu.milliseconds
                @santa.stamina -= @stamina_cost
            end
        when Gosu::KB_S
            if (@santa.y == GROUND and

                @santa.slide_cooldown == 3 and
                !@santa.is_jumping and
                !@santa.is_sliding)

                @slide_offset = Gosu.milliseconds
                @santa.vx = -20
                @santa.slide_cooldown = 0
            end
        when Gosu::MsLeft
            case @scene
            when :menu
                if mouse_y.between?(200, 300) and mouse_x.between?(450, 800)
                    @scene = :playing
                elsif mouse_y.between?(300, 400) and mouse_x.between?(450, 800)
                    @difficulty > 1 ? @difficulty -= 1 : @difficulty = 3
                elsif mouse_y.between?(500, 600) and mouse_x.between?(450, 800)
                    @scene = :tutorial
                elsif mouse_y.between?(600, 700) and mouse_x.between?(450, 800)
                    close
                end
            when :paused
                if mouse_y.between?(400, 500) and mouse_x.between?(450, 800)
                    # pausing the game
                    if !@santa.is_alive then reset_game end
                    @scene = :playing
                elsif mouse_y.between?(500, 600) and mouse_x.between?(450, 800)
                    #quitting the game
                    @high_score = update_record(@interface.score)
                    reset_game
                    @scene = :menu
                end
            when :tutorial
                if mouse_y.between?(600, 700) and mouse_x.between?(450, 600)
                    @scene = :menu
                end
            end
        when Gosu::KB_SPACE
            @scene == :playing ? @scene = :paused : @scene = :playing
        end
    end
end

SantaGame.new.show if __FILE__ == $0