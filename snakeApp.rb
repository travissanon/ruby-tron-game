require 'ruby2d'

# Default width/height is 640 by 480
set title: "Hello Snake"

def rand_num(n)
  (rand(n) / 10).round * 10.0
end

@height = get :height
@width = get :width
@length = 10
@cached_key

@snake1 = []
@position1 = []

@snake2 = []
@position2 = []

@cached_inputs = []

i = 0
while i < @length do
  @snake1 << Square.new(size: 10, x: (@length - i)*10, y: 0, color: "white")
  @snake2 << Square.new(size: 10, x: @width - (@length - i)*10, y: @height - 10, color: "red")
  i += 1
end

def copy_snake_position_1(snake_type, position_type)
  snake_type[0..-2].each do |s|
    position_type << [s.x, s.y]
  end
end

def copy_snake_position_2(snake_type, position_type)
  snake_type[0..-2].each do |s|
    position_type << [s.x, s.y]
  end
end

def move_snake_head_1(key, snake_type)
  if @cached_inputs.length < 1
    snake_type[0].x = snake_type[0].x + 10
    sleep 0.070
  else
    case @cached_key
    when "up"
      snake_type[0].y = snake_type[0].y - 10
      sleep 0.070
    when "down"
      snake_type[0].y = snake_type[0].y + 10
      sleep 0.070
    when "left"
      snake_type[0].x = snake_type[0].x - 10
      sleep 0.070
    when "right"
      snake_type[0].x = snake_type[0].x + 10
      sleep 0.070
    end
  end
end

def move_snake_head_2(key, snake_type)
  if @cached_inputs.length < 1
    snake_type[0].x = snake_type[0].x - 10
    sleep 0.070
  else
    case @cached_key
    when "w"
      snake_type[0].y = snake_type[0].y - 10
      snake_1_key = "w"
      sleep 0.070
    when "s"
      snake_type[0].y = snake_type[0].y + 10
      sleep 0.070
    when "a"
      snake_type[0].x = snake_type[0].x - 10
      sleep 0.070
    when "d"
      snake_type[0].x = snake_type[0].x + 10
      sleep 0.070
    end

  end
end

def move_snake_body(snake_type, position_type)
  position_type.each_with_index do |p, i|
    snake_type[i+1].x = p[0]
    snake_type[i+1].y = p[1]
  end

  position_type.clear
end

Thread.new {
  on :key_down do |e|
    if ["up", "down", "left", "right"].include? e.key
      @cached_inputs.push(e.key)
      @cached_key = e.key
    end
  end
}

Thread.new {
  on :key_down do |e|
    if ["w", "s", "a", "d"].include? e.key
      @cached_inputs.push(e.key)
      @cached_key = e.key
    end
  end
}

def snake1_initialize
  copy_snake_position_1(@snake1, @position1)
  move_snake_head_1(@cached_inputs, @snake1)
  move_snake_body(@snake1, @position1)
  @cached_inputs.shift if @cached_key != @cached_inputs[0]
end

def snake2_initialize
  copy_snake_position_2(@snake2, @position2)
  move_snake_head_2(@cached_inputs, @snake2)
  move_snake_body(@snake2, @position2)
  @cached_inputs.shift if @cached_key != @cached_inputs[0]
end

update do
  snake1_initialize
  snake2_initialize
end

show
