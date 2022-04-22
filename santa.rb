
class Santa
  attr_accessor :y, :is_dying, :is_alive, :health, :stamina, :on_platform, :status

  def initialize(x, y)
    @x = x
    @y = y
    @vx = @vy = 0
    load_images
    @is_dying = false
    @is_alive = true
    @health = @stamina = 100
    @status = 'running'
  end

  def load_images
    @run_image = Gosu::Image.load_tiles("../media/santa/santa_run.png", 2741 / 11, 171)
    @slide_image = Gosu::Image.load_tiles("../media/santa/santa_slide.png", 2741 / 11, 171)
    @jump_image = Gosu::Image.load_tiles("../media/santa/santa_jump.png", 3987 / 16, 171)
    @die_image = Gosu::Image.load_tiles('../media/santa/santa_die.png', 4236 / 17, 171)
  end

  def draw
    @current_image.draw_rot(@x, @y, ZOrder::PLAYER,0)
  end

  def lose_health(damage)
    @health -= damage
  end

  def lose_stamina(damage)
    @stamina -= damage
  end

  def update
    @is_alive = false if @current_image == @die_image[@die_image.size - 1]
    control_jump_animation
    control_slide_animation
    update_status
    control_energy
    gain_stamina
  end

  def run_on_platform
    @on_platform = true
  end

  def run_on_ground
    @on_platform = false
  end

  def gain_stamina
    @stamina += 3.5 / 60.to_f unless @stamina >= 100
  end

  def gain_health
    @health += 10
  end

  def control_energy
    @stamina = 0 if @stamina.negative?
    @health = 0 if @health.negative?
    @stamina = 100 if @stamina >= 100
    @health = 100 if @health >= 100
  end

  def control_jump_animation
    @vy += 1
    if @vy.positive?
      @vy.times {
        (@y < GROUND) && !@on_platform ? @y += 1 : @vy = 0
      }
    elsif @vy.negative?
      (-@vy).times { @y -= 1}
    end
  end

  def control_slide_animation
    @vx += 1 if @vx.negative?
  end

  def update_status
    @status = if @vx.negative?
                'sliding'
              elsif (@y < GROUND) && !@on_platform
                'jumping'
              else
                'running'
              end
  end

  def jump_allowed?(stamina_cost)
    if (@y == GROUND || @on_platform) && (@stamina >= stamina_cost)
      true
    else
      false
    end
  end

  def slide_allowed?(stamina_cost)
    if @y == GROUND && @stamina >= stamina_cost 
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
    @current_image = @jump_image[(Gosu.milliseconds - @jump_offset) / 45 % 16]
  end

  def slide
    @current_image = @slide_image[(Gosu.milliseconds - @slide_offset) / 45 % 11]
  end

  def die
    @is_dying = true
    @current_image = @die_image[(Gosu.milliseconds - @die_offset) / 110 % 17]
  end
end
