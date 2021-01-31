

require 'rubygems'
require 'gosu'
require './map.rb'
require './santa.rb'
require './interface.rb'
require './monsters.rb'
require './platform.rb'
require './trap.rb'

# CHANGES: the player cannot move horizontally and a tutorial is added

HEIGHT = 800
WIDTH = 1300

GROUND = 630

MAX_TRAP_AMOUNT = 2
MAX_MONSTER_AMOUNT = 4
MAX_PLATFORM_AMOUNT = 3

module ZOrder
  BACKGROUND1, BACKGROUND2, BACKGROUND3, BACKGROUND4, TRAP, GROUND, PLAYER, UI = *1..8
end

Monster_Action = ['idle', 'walk']
Monster_Type = ['dragon', 'medusa', 'demon']
Aerial_Monster = ['fly']

class SantaGame < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = 'Game'

    @audio = Gosu::Song.new('media/soundtrack.mp3')
    @difficulty = 3

    @stamina_cost = 12.5
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

    @santa = Santa.new(400, GROUND)
    @map = Map.new
    @interface = Interface.new(@difficulty)

    @monster_horde = []
    @aerial_monster_horde = []
    @platform_set = []
    @trap_set = []
    @scene = :menu

    @pause_message = 'GAME PAUSED'
    @prompt = 'RESUME'

    record_file = File.open('highscore.txt', 'r')
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
      @interface.draw_player_status(@santa.health, @santa.stamina)
      @santa.draw
      @map.draw


      @platform_set.each(&:draw) unless @platform_set.size.zero?
      @monster_horde.each(&:draw) unless @monster_horde.size.zero?
    end
  end

  def in_monster_range?(monster_x, player_y)
    monster_x.between?(390, 460) and player_y == GROUND
  end

  def in_fly_range?(fly_x, player_y)
    fly_x.between?(360, 440) and player_y.between?(-360, 440) ? true : false
  end

  # def in_santa_range?(monster_x, player_y)
  #   monster_x.between?(390, 480) and player_y == GROUND
  # end

  def in_trap_range?(player_y, trap_x)
    trap_x.between?(390, 410) and player_y == GROUND
  end

  def in_platform_range?(player_y, platform_x)
    platform_x.between?(180, 410) and player_y.between?(415, 421) ? true : false
  end

  def needs_cursor?
    true
  end

  def update
    case @scene
    when :menu
      @audio.pause
      @stamina_cost = 12.5
      @score_gain = 1 / 60.to_f

      case @difficulty
      when 3
        @monster_frequency = 250
        @fly_frequency = 300
        @monster_damage = 20 / 60.to_f
        @aerial_monster_damage = 0.02
        @platform_frequency = 200
      when 2
        @monster_frequency = 230
        @fly_frequency = 270
        @monster_damage = 22 / 60.to_f
        @aerial_monster_damage = 0.03
        @platform_frequency = 220
      when 1
        @monster_frequency = 200
        @fly_frequency = 250
        @monster_damage = 24 / 60.to_f
        @aerial_monster_damage = 0.04
        @platform_frequency = 240
      end
    when :paused

      @audio.play(true)
      @santa.update
      @santa.die if @santa.is_dying

    when :playing

      @audio.play(false)
      @map.update
      @santa.update
      @interface.update(@score_gain)

      if @santa.health <= 0
        @prompt = 'PLAY AGAIN'
        @pause_message = 'GAME OVER'
        @scene = :paused
      end

      unless @monster_horde.empty?
          @monster_horde.each { |monster|
              monster.update
              if in_monster_range?(monster.x, @santa.y) && !monster.is_dying
                if @santa.status == 'sliding'
                  monster.gets_hit
                else
                  monster.attack
                  @santa.lose_health(@monster_damage)
                end
              elsif monster.is_dying  
                monster.die
              else
                monster.move
              end
          }
          @monster_horde.reject! { |monster| monster.x < 0 || monster.is_dead }
      end

    unless @platform_set.empty?
        @platform_set.each(&:update)
        @platform_set.reject! {|platform| platform.x < -110 }
        if in_platform_range?(@santa.y, @platform_set[0].x)
          @santa.run_on_platform
        else
          @santa.run_on_ground
        end

    end

    unless @aerial_monster_horde.empty?
      @aerial_monster_horde.each {|fly|
          fly.update
          fly.move
          if in_fly_range?(fly.x, @santa.y)
              @santa.stamina >= 0.5 ? @santa.stamina -= @stamina_cost : @santa.stamina = 0
          end
      }
      @aerial_monster_horde.reject!{|fly| fly.x < -30 }
    end

      if rand(@monster_frequency).zero? && @monster_horde.size < MAX_MONSTER_AMOUNT
        if @monster_horde.empty?
            @monster_horde << get_monster(1400)
        else
          last_monster = @monster_horde.last
          @monster_horde << get_monster(last_monster.x)
        end
      end

      if rand(@platform_frequency).zero? && @platform_set.size < MAX_PLATFORM_AMOUNT
        if @platform_set.empty?
            platform_x = 1500
        else
            last_platform = @platform_set[@platform_set.size - 1]
            last_platform.x < 700 ? platform_x = 1500 : platform_x = last_platform.x + 800
        end

        @platform_set << Platform.new(platform_x, 485)
    end

      if @santa.status == 'running'
          @santa.run_forward
      elsif @santa.status == 'jumping'
          @santa.jump
      else
          @santa.slide
      end


    end
  end

  def get_monster(last_monster_x)
    last_monster_x < 1200 ? new_x = 1400 : new_x = last_monster_x + 200
    case rand(3)
    when 0
      Demon.new(new_x, GROUND, Monster_Action[rand(2)])
    when 1
      Medusa.new(new_x, GROUND, Monster_Action[rand(2)])
    else
      Dragon.new(new_x, GROUND, Monster_Action[rand(2)])
    end
  end

  def update_record(high_score)
    record_file = File.open('highscore.txt', 'r')
    record_high_score = record_file.gets.to_i

    if record_high_score < high_score
      new_high_score = high_score.to_s
      record_file = File.open('highscore.txt', 'w')
      record_file.write(new_high_score)
      record_file.close
      
      high_score
    end

    record_high_score
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
      if @santa.jump_allowed?(@stamina_cost)
        @santa.set_up_jump(@stamina_cost)
      end
    when Gosu::KB_S
      if @santa.slide_allowed?(@stamina_cost)
        @santa.set_up_slide(@stamina_cost)
      end
    when Gosu::MsLeft
      case @scene
      when :menu
        if mouse_y.between?(200, 300) && mouse_x.between?(450, 800)
          @scene = :playing
        elsif mouse_y.between?(300, 400) && mouse_x.between?(450, 800)
          @difficulty > 1 ? @difficulty -= 1 : @difficulty = 3
        elsif mouse_y.between?(500, 600) && mouse_x.between?(450, 800)
          @scene = :tutorial
        elsif mouse_y.between?(600, 700) && mouse_x.between?(450, 800)
          close
        end
      when :paused
        if mouse_y.between?(400, 500) && mouse_x.between?(450, 800)
          # pausing the game
          reset_game unless @santa.is_alive
          @scene = :playing
        elsif mouse_y.between?(500, 600) && mouse_x.between?(450, 800)
          # quitting the game
          @high_score = update_record(@interface.score)
          reset_game
          @scene = :menu
        end
      when :tutorial
        @scene = :menu if mouse_y.between?(600, 700) && mouse_x.between?(450, 600)
      end
    when Gosu::KB_SPACE
      @scene = @scene == :playing ? :paused : :playing
    end
  end
end

SantaGame.new.show if __FILE__ == $PROGRAM_NAME
