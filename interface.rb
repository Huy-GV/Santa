HEALTH_COLOR = Gosu::Color.rgb(85, 255, 0)
STAMINA_COLOR = Gosu::Color.argb(0xff_00ffff)
ATTACK_COLOR = Gosu::Color::RED 

class Interface
    attr_accessor :difficulty, :score
    def initialize(difficulty)
        @difficulty = difficulty
        @score = 0
    end

    def update(score_gain)
        @score += score_gain
        @score.round
    end

    def draw_player_status(player_health, player_stamina, player_cooldown)
        Gosu::Image.new("media/interface/heart.png").draw_rot(20, 45, ZOrder::UI, 0)
        Gosu.draw_quad(
            40, 30, Gosu::Color::YELLOW, 
            40, 80, Gosu::Color::YELLOW, 
            45, 30, Gosu::Color::YELLOW, 
            45, 80, Gosu::Color::YELLOW, ZOrder::UI)
        Gosu.draw_quad(
            45, 30, HEALTH_COLOR, 
            45, 60, HEALTH_COLOR, 
            45 + (player_health / difficulty.to_f) * 170, 30, HEALTH_COLOR, 
            45 + (player_health / difficulty.to_f) * 170, 60, HEALTH_COLOR, ZOrder::UI)

        Gosu.draw_quad(
            45, 60, STAMINA_COLOR, 
            45, 70, STAMINA_COLOR, 
            45 + (player_stamina / difficulty.to_f) * 170, 60, STAMINA_COLOR, 
            45 + (player_stamina / difficulty.to_f) * 170, 70, STAMINA_COLOR, ZOrder::UI)
        Gosu.draw_quad(
            45, 70, ATTACK_COLOR, 
            45, 80, ATTACK_COLOR, 
            45 + (player_cooldown / difficulty.to_f) * 170, 70, ATTACK_COLOR, 
            45 + (player_cooldown / difficulty.to_f) * 170, 80, ATTACK_COLOR, ZOrder::UI)
        Gosu.draw_quad(
            210, 30, Gosu::Color::YELLOW, 
            210, 80, Gosu::Color::YELLOW, 
            215, 30, Gosu::Color::YELLOW, 
            215, 80, Gosu::Color::YELLOW, ZOrder::UI)
        Gosu.draw_line(45, 60, Gosu::Color::BLUE, 210, 60, Gosu::Color::BLUE, ZOrder::UI, mode=:default)
    end


    def draw_menu_options(difficulty, high_score)

        case difficulty
        when 3
            difficulty = 'EASY'
            difficulty_color = Gosu::Color::GREEN
        when 2 
            difficulty = 'NORMAL'
            difficulty_color = Gosu::Color::YELLOW
        when 1
            difficulty = 'HARD'
            difficulty_color = Gosu::Color::RED
        end
        
        Gosu::Font.new(50).draw("WELCOME TO SANTA IN THE WOODS", 250, 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        Gosu::Font.new(50).draw("PLAY", 450, 200, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        Gosu::Font.new(50).draw("DIFFICULTY: ", 450, 300, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        Gosu::Font.new(50).draw(difficulty, 730, 300, ZOrder::UI, 1.0, 1.0, difficulty_color )
        Gosu::Font.new(50).draw("HIGH SCORE: #{high_score.round}", 450, 400, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        Gosu::Font.new(50).draw("EXIT", 450, 500, ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
    end

    def draw_pause_options(pause_message, prompt)
        Gosu.draw_quad(
            400, 150, Gosu::Color::BLACK, 
            400, 600, Gosu::Color::BLACK, 
            800, 150, Gosu::Color::BLACK, 
            800, 600, Gosu::Color::BLACK, ZOrder::UI)
        Gosu::Font.new(50).draw(pause_message, 450, 200, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        Gosu::Font.new(50).draw("SCORE: #{@score.round}", 450, 300, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        Gosu::Font.new(50).draw(prompt, 450, 400, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN)
        Gosu::Font.new(50).draw('QUIT', 450, 500, ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
    end

    def draw_score
        Gosu::Font.new(30).draw("SCORE: #{@score.round}", 1000, 17, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end
end