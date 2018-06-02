require 'ruby2d'

set title: 'Howdy', background: 'navy', width: 1280, height: 720

@height = get :height
@width = get :width
@colors = ["blue", "aqua", "teal", "olive", "green", "lime", "yellow", "orange", "red", "silver", "white", "fuchsia"]
@ready = false

class Snake
  def initialize(up, down, left, right, color, width, height, player)
    @length = 1
    @snake = []
    @positions = []
    @cached_key
    @cached_inputs = []
    @move = [up, down, left, right]
    @color = color
    @height = height
    @width = width
    @player = player
    @score = score
    @points = 0
  end

  def rand_num(n)
    (rand(n) / 10).round * 10.0
  end

  def update_cache(key)
    @cached_inputs.push(key)
    @cached_key = key
  end

  def shift_cached_inputs
    @cached_inputs.shift if @cached_key != @cached_inputs[0]
  end

  def create_snake
    height = rand_num(@height)
    width = rand_num(@width)
    i = 0
    while i < @length do
      @snake << Square.new(size: 10, x: width - (@length - i)*10, y: height - 10, color: "red")
      i += 1
    end
  end

  # def copy_snake_position
  #   @snake[0..-2].each do |s|
  #     @positions << [s.x, s.y]
  #   end
  # end

  def copy_head_position
    Square.new(size: 10, x: @snake[0].x, y: @snake[0].y, color: @color)
    @positions << [@snake[0].x, @snake[0].y]
  end

  def move_snake_head(up, down, left, right)
    if @cached_inputs.length < 1
      @snake[0].x = @snake[0].x + 10
      sleep 0.020
    else
      case @cached_inputs[0]
      when up
        @snake[0].y = @snake[0].y - 10
        sleep 0.020
      when down
        @snake[0].y = @snake[0].y + 10
        sleep 0.020
      when left
        @snake[0].x = @snake[0].x - 10
        sleep 0.020
      when right
        @snake[0].x = @snake[0].x + 10
        sleep 0.020
      end
    end
  end

  def move_snake_body
    @positions.each_with_index do |p, i|
      @snake[i+1].x = p[0]
      @snake[i+1].y = p[1]
    end
    @positions.clear
  end

  def border_check
    # p "x: #{@snake[0].x}, y: #{@snake[0].y}"
    @snake[0].x = 0 if @snake[0].x == @width
    @snake[0].x = @width if @snake[0].x == -10
    @snake[0].y = 0 if @snake[0].y == @height
    @snake[0].y = @height if @snake[0].y == -10
  end

  def head_position
    [@snake[0].x, @snake[0].y]
  end

  def body
    @positions
  end

  def add_length
    @snake << Square.new(size: 10, x: @snake[-1].x - 10, y: @snake[-1].y - 10, color: @color)
  end

  def pop_length
    @snake.pop
  end

  def score
    Text.new(x: 10, y: 30 * @player, text: "P#{@player} [ #{@move[0].upcase} #{@move[1].upcase} #{@move[2].upcase} #{@move[3].upcase} ]", size: 18, font: 'Roboto-Black.ttf', color: @color)
  end

  def win
    Square.new(size: 350, x: (@width / 2) - 175, y: (@height / 2) - 175, color: "red")
    Text.new(x: (@width / 2) - 150, y: (@height / 2) - 125, text: "P#{@player}", size: 125, font: 'Roboto-Black.ttf', color: "white")
    Text.new(x: (@width / 2) - 150, y: (@height / 2), text: "WINS", size: 110, font: 'Roboto-Black.ttf', color: "white")
  end

  def snake_init
    copy_head_position
    move_snake_head(@move[0], @move[1], @move[2], @move[3])
    shift_cached_inputs
    border_check
  end
end

@player_one = Snake.new("up", "down", "left", "right", @colors[rand(@colors.length)], @width, @height, 1)
@player_one.create_snake

@player_two = Snake.new("w", "s", "a", "d", @colors[rand(@colors.length)], @width, @height, 2)
@player_two.create_snake

Thread.new {
  on :key_down do |e|
    if ["up", "down", "left", "right"].include? e.key
      @player_one.update_cache(e.key)
    end
  end
}

Thread.new {
  on :key_down do |e|
    if ["w", "s", "a", "d"].include? e.key
      @player_two.update_cache(e.key)
    end
  end
}

def restart
  sleep 3
  exec( "ruby class.rb" )
end

def collision_detection
  player_one_body = @player_one.body
  player_two_body = @player_two.body

  player_one_body.each do |p|
    if @player_two.head_position == p || @player_one.head_position == p
      @player_one.win
      @ready = true
    end
  end

  player_two_body.each do |p|
    if @player_one.head_position == p || @player_two.head_position == p
      @player_two.win
      @ready = true
    end
  end
end

@player_one.score
@player_two.score

update do
  @player_one.snake_init
  @player_two.snake_init
  collision_detection
  if @ready == true
    restart
  end
end

show
