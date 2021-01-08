require 'rubygems'
require 'gosu'
require './map.rb'
require './santa.rb'
require './interface.rb'
require './monsters.rb'
require './platform.rb'
require './trap.rb'

HEIGHT = 800
WIDTH = 1200
FULL_BACKGROUND_WIDTH = 1741
GROUND = 630

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
        @audio.play(true)

        @difficulty = 3

        @santa = Santa.new(300, GROUND)
        @map = Map.new
        @interface = Interface.new(@difficulty)

        @monster_horde = Array.new
        @aerial_monster_horde = Array.new
        @platform_set = Array.new
        @trap_set = Array.new
        @scene = :menu

        case @difficulty
        when 3
            @monster_frequency = 270
            @fly_frequency = 330
            @stamina_loss = 0.4
            @monster_damage = 1 / 60.to_f
            @aerial_monster_damage = 0.25
            @score_gain = 1/60.to_f
            @platform_frequency = 180
            @trap_frequency = 250
        when 2
            @monster_frequency = 250
            @fly_frequency = 230
            @stamina_loss = 0.5
            @monster_damage = 1.5 / 60.to_f
            @aerial_monster_damage = 0.35
            @score_gain = 1.5/60.to_f
            @platform_frequency = 200
            @trap_frequency = 230
        when 1
            @monster_frequency = 230
            @fly_frequency = 270
            @stamina_loss = 0.6
            @monster_damage = 1.7 / 60.to_f
            @aerial_monster_damage = 0.45
            @score_gain = 2/60.to_f
            @platform_frequency = 220
            @trap_frequency = 210
        end

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

    def in_monster_range?(monster_x, monster_y, player_x, player_y)
        (monster_x - player_x).between?(-70, 70) and (monster_y - player_y).abs < 65 ? true : false
    end
    # santa loses stamina + health when hit by fly 
    def in_fly_range?(fly_x, fly_y, player_x, player_y)
        (fly_x - player_x).between?(-40, 40) and (fly_y - player_y).between?(-40, 40) ? true : false
    end

    def in_trap_range?(player_x, player_y, trap_x)
        (trap_x - player_x).between?(-50, 50) and player_y.between?(600, GROUND) ? true : false
    end

    def in_platform_range?(player_x, player_y, platform_x, platform_y)
        player_x.between?(platform_x - 115, platform_x + 115) and player_y.between?(415,421) ? true : false
    end

    def on_any_platform?(player_x, player_y, platform_set)
        # for i in 0..(platform_set.size - 1)
        #     if in_platform_range?(player_x, player_y, platform_set[i].x, platform_set[i].y)
        #         return true
        #     end
        # end

        platform_set.each{|platform| if in_platform_range?(player_x, player_y, platform.x, platform.y) then return true end}
        return false
    end

    def needs_cursor?; true; end

    def update
        if ((@santa.y == GROUND or @santa.on_platform) and
            @santa.stamina > 0.6 and 
            !@santa.is_sliding and 
            !@santa.is_jumping)
            @santa.can_jump = true
        else
            @santa.can_jump = false
        end
      
        case @scene
        when :menu
            case @difficulty
            when 3
                @monster_frequency = 250
                @fly_frequency = 300
                @stamina_loss = 0.6
                @monster_damage = 1 / 60.to_f
                @aerial_monster_damage = 0.3
                @score_gain = 1 / 60.to_f
            when 2
                @monster_frequency = 230
                @fly_frequency = 270
                @stamina_loss = 0.7
                @monster_damage = 1.5 / 60.to_f
                @aerial_monster_damage = 0.4
                @score_gain = 2 / 60.to_f
            when 1
                @monster_frequency = 200
                @fly_frequency = 250
                @stamina_loss = 0.8
                @monster_damage = 1.7 / 60.to_f
                @aerial_monster_damage = 0.5
                @score_gain = 3 / 60.to_f
            end
        when :paused
            @santa.update
            if @santa.is_dying
                @audio.pause
                @santa.die(@die_offset)
            end
        when :playing
            # @map.roll
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

                    if in_monster_range?(monster.x, monster.y, @santa.x, @santa.y) and monster.action != 'DYING'
                        monster.action = 'ATTACKING'
                        if @santa.is_sliding
                            monster.die_offset = Gosu.milliseconds
                            monster.action = 'DYING'
                            monster.is_hit = true
                        else
                            @santa.health -= @monster_damage
                        end
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
                    if in_fly_range?(fly.x, fly.y, @santa.x, @santa.y)
                        @santa.stamina >= 0.5 ? @santa.stamina -= @stamina_loss : @santa.stamina = 0
                    end
                }
                @aerial_monster_horde.reject!{|fly| fly.x < -30 }
            end

            unless @platform_set.size == 0
                @platform_set.each { |platform|
                    platform.update
                }

                @platform_set.reject! {|platform|
                    platform.x < -110
                }

                @santa.on_platform = on_any_platform?(@santa.x, @santa.y, @platform_set)
            end

            unless @trap_set.size == 0
                @trap_set.reject! {|trap|
                    trap.x < -40
                }

                @trap_set.each {|trap|
                    trap.update
                    if (trap.x - @santa.x < 220) then trap.has_spiked = true end
                    if in_trap_range?(@santa.x, @santa.y, trap.x) then @santa.health -= 0.9 / 40 end
                }
            end

            if rand(@monster_frequency) == 0 and @monster_horde.size < 5
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

            if rand(@fly_frequency) == 0 and @aerial_monster_horde.size < 4
                aerial_monster_type = Aerial_Monster[rand(0..(Aerial_Monster.size - 1))]
                if @aerial_monster_horde.size == 0
                    fly_x = 1250
                else
                    last_fly = @aerial_monster_horde[@aerial_monster_horde.size - 1]
                    last_fly.x < 700 ? fly_x = 1300 : fly_x = last_fly.x + 600
                end

                @aerial_monster_horde << Flying_Goblin.new(fly_x, 400, aerial_monster_type, 'MOVING')
            end

            if rand(@platform_frequency) == 0 and @platform_set.size < 3
                if @platform_set.size == 0
                    platform_x = 1500
                else
                    last_platform = @platform_set[@platform_set.size - 1]
                    last_platform.x < 700 ? platform_x = 1400 : platform_x = last_platform.x + 700
                end
                @platform_set << Platform.new(platform_x, 500)
            end

            if rand(@trap_frequency) == 0 and @trap_set.size < 2
                if @trap_set.size == 0 
                    trap_x = 1300
                else
                    last_trap = @trap_set[@trap_set.size - 1]
                    last_trap.x < 700 ? trap_x = 1300 : trap_x = last_trap.x + 600
                end

                @trap_set << Trap.new(trap_x)
            end

            if !(@santa.is_jumping or @santa.is_sliding)
                if (button_down?(Gosu::KB_D))
                    @santa.run_forward
                    @santa.is_sliding = false
                elsif (button_down?(Gosu::KB_A))
                    @santa.run_backward
                    @santa.is_sliding = false
                else
                    @santa.idle
                end
            elsif @santa.is_jumping
                @santa.is_sliding = false
                @santa.jump(@jump_offset)
                @santa.x += 4 if button_down?(Gosu::KB_D)
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
        @santa = Santa.new(300, GROUND)
        @map = Map.new
    end
        
    def button_down(id)
        case id
        when Gosu::KB_W
            if @santa.can_jump
                @santa.vy = -25
                @jump_offset = Gosu.milliseconds
                @santa.stamina -= @stamina_loss
            end
        when Gosu::KB_S
            if (@santa.y == GROUND and
                @santa.slide_cooldown == @difficulty and
                !@santa.is_jumping and
                !@santa.is_sliding)

                @slide_offset = Gosu.milliseconds
                @santa.vx = -13
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
                    close
                end
            when :paused
                if mouse_y.between?(400, 500) and mouse_x.between?(450, 800)
                    # pausing the game
                    if !@santa.is_alive then reset_game end
                    @scene = :playing
                elsif mouse_y.between?(500, 600) and mouse_x.between?(450, 800)
                    #quitting the game
                    @santa = Santa.new(300, GROUND)
                    @high_score = update_record(@interface.score)
                    reset_game
                    @scene = :menu
                end
            end
        when Gosu::KB_SPACE
            @scene == :playing ? @scene = :paused : @scene = :playing
        end
    end
end

SantaGame.new.show if __FILE__ == $0