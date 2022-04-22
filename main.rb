require 'rubygems'
require 'gosu'
require './map.rb'
require './santa.rb'
require './menu.rb'
require './monsters.rb'
require './platform.rb'
require './trap.rb'

HEIGHT = 800
WIDTH = 1200

GROUND = 630

MAX_TRAP_AMOUNT = 2
MAX_MONSTER_AMOUNT = 4
MAX_AERIAL_MONSTER_AMOUNT = 4
MAX_PLATFORM_AMOUNT = 3

module ZOrder
  BACKGROUND1, BACKGROUND2, BACKGROUND3, BACKGROUND4, TRAP, GROUND, PLAYER, UI = *1..8
end

MONSTER_CONSTANT = %w[idle walk].freeze
MONSTER_TYPE = %w[dragon medusa demon].freeze
AERIAL_MONSTER = %w[fly].freeze

class SantaGame < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = 'Game'

    @audio = Gosu::Song.new('../media/soundtrack.mp3')
    @difficulty = 3

    @stamina_cost = 12.5
    @score_gain = 1 / 60.to_f

    @santa = Santa.new(400, GROUND)
    @map = Map.new
    @interface = Interface.new(@difficulty)
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

      @platform_set.each(&:draw) unless @platform_set.empty?
      @monster_horde.each(&:draw) unless @monster_horde.empty?
      @aerial_monster_horde.each(&:draw) unless @aerial_monster_horde.empty?
    end
  end

  def in_monster_range?(monster_x, player_y)
    monster_x.between?(390, 460) and player_y == GROUND
  end

  def in_fly_range?(fly_x, player_y)
    fly_x.between?(360, 440) and player_y.between?(-360, 440) ? true : false
  end

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
        @santa.start_die_animation
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
              @santa.gain_health
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

      if @platform_set.empty?
        @santa.run_on_ground
      else
        @platform_set.each(&:move)
        @platform_set.reject! { |platform| platform.x < -110 }
        
        if !@platform_set.empty? && in_platform_range?(@santa.y, @platform_set[0].x)
          @santa.run_on_platform
        else
          @santa.run_on_ground
        end
      end

      unless @aerial_monster_horde.empty?
        @aerial_monster_horde.each{ |aerial_monster|
          aerial_monster.move
          @santa.lose_stamina(@aerial_monster_damage) if in_fly_range?(aerial_monster.x, @santa.y)
        }

        @aerial_monster_horde.reject!{ |fly| fly.x < -30 }
      end

      if rand(@monster_frequency).zero? && @aerial_monster_horde.size < MAX_AERIAL_MONSTER_AMOUNT
        if @aerial_monster_horde.empty?
          @aerial_monster_horde << get_aerial_monster(1400)
        else
          last_monster = @aerial_monster_horde.last
          @aerial_monster_horde << get_aerial_monster(last_monster.x)
        end
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
          platform_x = last_platform.x < 700 ? 1500 : last_platform.x + 800
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
    new_x = last_monster_x < 1200 ? 1400 : last_monster_x + 200
    case rand(3)
    when 0
      Demon.new(new_x, GROUND, MONSTER_CONSTANT[rand(2)])
    when 1
      Medusa.new(new_x, GROUND, MONSTER_CONSTANT[rand(2)])
    else
      Dragon.new(new_x, GROUND, MONSTER_CONSTANT[rand(2)])
    end
  end

  def get_aerial_monster(last_monster_x)
    new_x = last_monster_x < 1200 ? 1400 : last_monster_x + 200
    Cyclop.new(new_x, 400)
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
    @santa = Santa.new(400, GROUND)
    @map = Map.new
  end

  def set_up_game(difficulty)
    case difficulty
    when 3
      @monster_frequency = 220
      @fly_frequency = 300
      @monster_damage = 40 / 60.to_f
      @aerial_monster_damage = 40 / 60.to_f
      @platform_frequency = 200
    when 2
      @monster_frequency = 210
      @fly_frequency = 270
      @monster_damage = 50 / 60.to_f
      @aerial_monster_damage = 50 / 60.to_f
      @platform_frequency = 220
    when 1
      @monster_frequency = 200
      @fly_frequency = 250
      @monster_damage = 60 / 60.to_f
      @aerial_monster_damage = 60 / 60.to_f
      @platform_frequency = 240
    end

    @monster_horde = []
    @aerial_monster_horde = []
    @platform_set = []
    @trap_set = []
  end

  def button_down(id)
    case id
    when Gosu::KB_W
      @santa.set_up_jump(@stamina_cost) if @santa.jump_allowed?(@stamina_cost)
    when Gosu::KB_S
      @santa.set_up_slide(@stamina_cost) if @santa.slide_allowed?(@stamina_cost)
    when Gosu::MsLeft
      case @scene
      when :menu
        if mouse_y.between?(200, 300) && mouse_x.between?(450, 800)
          set_up_game(@difficulty)
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
          unless @santa.is_alive
            reset_game
            set_up_game(@difficulty)
          end
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
      @scene = :paused if @scene == :playing
    end
  end
end

SantaGame.new.show if __FILE__ == $PROGRAM_NAME
