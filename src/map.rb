
class Map

  def initialize
    @bg = Gosu::Image.new("../media/backgrounds/bg_color.png")
    @farground = Gosu::Image.new("../media/backgrounds/far.png", :tileable => true)
    @midground = Gosu::Image.new( "../media/backgrounds/mid.png", :tileable => true)
    @ground = Gosu::Image.new("../media/backgrounds/ground.png",:tileable => true)
    @closeground = Gosu::Image.new( "../media/backgrounds/close.png", :tileable => true)  
    @farground_x = @midground_x = @closeground_x = @ground_x = 0
 end

  def draw
    @bg.draw_rot(WIDTH / 2, 400, ZOrder::BACKGROUND1, 0)
    draw_farground
    draw_midground
    draw_closeground
    draw_ground
  end

  def draw_farground
    @farground.draw(@farground_x, 0, ZOrder::BACKGROUND3)
    @farground.draw(@farground_x + @farground.width , 0, ZOrder::BACKGROUND3)
  end

  def draw_midground
    @midground.draw(@midground_x, 0, ZOrder::BACKGROUND3)
    @midground.draw(@midground_x + @midground.width , 0, ZOrder::BACKGROUND3)
  end

  def draw_closeground
    @closeground.draw(@closeground_x, 0, ZOrder::BACKGROUND3)
    @closeground.draw(@closeground_x + @closeground.width ,0, ZOrder::BACKGROUND3)
  end

  def draw_ground
    @ground.draw(@ground_x, 700, ZOrder::GROUND)
    @ground.draw(@ground_x + @ground.width, 700, ZOrder::GROUND)
  end

  def update
    roll_farground
    roll_midground
    roll_closeground
    roll_ground
  end

  def roll_farground
    @farground_x <= -@farground.width ? @farground_x = 0 : @farground_x -= 1
  end

  def roll_midground
    @midground_x <= -@midground.width ? @midground_x = 0 : @midground_x -= 1.5
  end

  def roll_closeground
    @closeground_x <= -@closeground.width ? @closeground_x = 0 : @closeground_x -= 2
  end

  def roll_ground
    @ground_x <= -@ground.width ? @ground_x = 0 : @ground_x -= 2
  end
end