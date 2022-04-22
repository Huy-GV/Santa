
WALK_SPEED = 4
SCREEN_ROLL_SPEED = 2

class Monster
  attr_accessor :is_dead, :is_dying, :x, :y
  def initialize(x, y, action)
    @x = x
    @y = y
    @action = action
    @is_dead = false
    @is_dying = false
    # @move_image = []
    # @attack_image = []
  end

  def gets_hit
    @is_dying = true
    @die_offset = Gosu.milliseconds
  end

  def update
    @is_dead = @current_image == @last_dying_image ? true : false
  end

  def move
    @current_image = @move_image[Gosu.milliseconds / 150 % @move_image.size]
    @x -= @speed
  end

  def draw
    @current_image.draw_rot(@x, @y, ZOrder::PLAYER, 0)
  end

  def attack
    @x -= SCREEN_ROLL_SPEED * 0.5
    @current_image = @attack_image[Gosu.milliseconds / 140 % @attack_image.size]
  end

  def die
    @current_image = @dying_image[(Gosu.milliseconds - @die_offset) / 230 % @dying_image.size]
    @x -= SCREEN_ROLL_SPEED
    @is_dying = true
  end

  def set_initial_sprites
    @current_image = @move_image[0]
    @last_dying_image = @dying_image[@dying_image.size - 1]
  end

end

class Demon < Monster 
  def initialize(x, y, action)
    super
    get_sprites
    get_movement_sprites(@action)
    set_initial_sprites
  end

  def get_sprites
    @attack_image = Gosu::Image.load_tiles('../media/monsters/demon_attack.png', 1288 / 4, 322)
    @dying_image = Gosu::Image.load_tiles('../media/monsters/demon_dying.png', 3200 / 10, 320)
  end

  def get_movement_sprites(action)
    case action
    when 'idle'
      @speed = SCREEN_ROLL_SPEED
      @move_image = Gosu::Image.load_tiles('../media/monsters/demon_idle.png', 963 / 3, 320)
    when 'walk'
      @speed = WALK_SPEED
      @move_image = Gosu::Image.load_tiles('../media/monsters/demon_moving.png', 1926 / 6, 320)
    end

  end
end

class Dragon < Monster
  attr_accessor 
  def initialize(x, y, action)
    super
    get_sprites
    get_movement_sprites(@action)
    set_initial_sprites
  end

  def get_sprites
    @attack_image = Gosu::Image.load_tiles('../media/monsters/dragon_attack.png', 1288 / 4, 322)
    @dying_image = Gosu::Image.load_tiles('../media/monsters/dragon_dying.png', 2880 / 9, 320)
  end

  def get_movement_sprites(action)
    case action
    when 'idle'
      @speed = 2
      @move_image = Gosu::Image.load_tiles('../media/monsters/dragon_idle.png', 964 / 3, 320)
    when 'walk'
      @speed = 4
      @move_image = Gosu::Image.load_tiles('../media/monsters/dragon_moving.png', 1606 / 5, 320)
    end
  end
end

class Medusa < Monster
  attr_accessor
  def initialize(x, y, action)
    super
    get_sprites
    get_movement_sprites(@action)
    set_initial_sprites
  end

  def get_sprites
    @attack_image = Gosu::Image.load_tiles('../media/monsters/medusa_attack.png', 1530 / 6, 254)
    @dying_image = Gosu::Image.load_tiles('../media/monsters/medusa_dying.png', 2540 / 10, 254)
  end

  def get_movement_sprites(action)
    case action
    when 'idle'
      @speed = 2
      @move_image = Gosu::Image.load_tiles('../media/monsters/medusa_idle.png', 765 / 3, 255)
    else
      @speed = 4
      @move_image = Gosu::Image.load_tiles('../media/monsters/medusa_moving.png', 1020 / 4, 255)
    end
  end
end

class Aerial_Monster
  attr_accessor :x

  def initialize(x, y)
    @x = x
    @y = y
    @speed = 7
  end

  def move
    @current_image = @move_image[Gosu.milliseconds / 150 % @move_image.size]
    @x -= @speed
  end

  def draw
    @current_image.draw_rot(@x, @y, ZOrder::PLAYER, 0)
  end

  def set_initial_sprites
    @current_image = @move_image[0]
  end
end

class Cyclop < Aerial_Monster
  def initialize(x, y)
    super
    get_movement_sprites
    set_initial_sprites
  end

  def get_movement_sprites
    @move_image = Gosu::Image.load_tiles("../media/monsters/fly.png",1200/6,200)
  end

end
