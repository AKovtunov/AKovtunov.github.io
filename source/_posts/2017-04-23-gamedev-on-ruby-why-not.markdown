---
layout: post
title: "Gamedev on Ruby? Why not!"
date: 2017-04-23 12:18:04 +0200
comments: true
categories:
---
> This is a copy of my [original post for Diatom Enterprises](http://www.diatomenterprises.com/gamedev-on-ruby-why-not/)

{% img center /images/ruby_snake/Screenshot-from-2016-08-17-034112.png %}

This article isn’t about big games with sophisticated graphics, nor will I be creating something like MMORPG (even though, I think it’s possible). In this article, I will be creating a terminal Snake Game.
I know a lot of developers; including myself, who got started in programming, because they were crazy about games. They wanted to create something similar to what they had played before, but in the end, for some reason they are doing programming that has nothing to do with gamedev. So in this article I will be going though the steps to create a simple game in [Ruby language](http://www.diatomenterprises.com/technologies/ruby-on-rails/), which most of us use for various web-applications.

<!--more-->

## PREPARATIONS

I prefer to use ruby 2.3.1 with structured code and folders. For the Snake Game, I recommend the following folder structure:
``` plain
ruby_snake/
–lib/
|– Files that will create game mechanics
–spec/
|– spec_helper.rb
|– Test files
Gemfile
start.rb
```

The `Gemfile` contains a few gems: RSpec for tests and Pry for debugging our application. `Gemfile`:
``` ruby
source 'https://rubygems.org'
gem 'rspec'
gem 'pry'
```

For `rspec`, setup a `spec_helper.rb`. This file will contain each lib file and configure RSpec for our needs. `spec/spec_helper.rb` should be included in each test.
``` ruby
Dir[File.expand_path('../lib/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
Dir[File.expand_path('../lib/errors/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end
```

## THE STRUCTURE OF THE GAME

Can you imagine all the game components? It should look something like this:
``` plain
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . x x x x . o .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
```
Here you can see the `Board`, the `Snake` and the `Food`.
In addition, you will need something that will connect all these things together – the `Game`.
Let’s look closely at these components.

## THE BOARD

The `Board` has a width and a length, in our sample the width is 9 and the length is 9.
``` plain
  1 2 3 4 5 6 7 8 9
1 . . . . . . . . .
2 . . . . . . . . .
3 . . . . . . . . .
4 . . . . . . . . .
5 . . . . . . . . .
6 . . . . . . . . .
7 . . . . . . . . .
8 . . . . . . . . .
9 . . . . . . . . .
```
So, let’s write some tests that will cover our Board.

``` ruby
require 'spec_helper'
describe Board do
  describe "#new" do
    it "initializes gameboard with board" do
      expect(Board.new(40,40).board).not_to be_nil
    end
  end
  describe "#create_board" do
    let(:gameboard){Board.new(40,40)}
    it "returns an array" do
      expect(gameboard.board).to be_instance_of(Array)
    end
    it "returns an array with given size" do
      expect(gameboard.board.size).to be_eql(40)
      expect(gameboard.board[0].size).to be_eql(40)
    end
    it "returns board full of . symbols" do
      expect(gameboard.board.first.first).to eql('.')
    end
  end
end
```

And specifically this will create our Board and its methods:

``` ruby
class Board
  attr_reader :length, :width, :board

  def initialize(width, length)
    @length = length
    @width = width
    create_board
  end

  def center
    [board.length/2, board.first.length/2]
  end

  def print_text(text)
    char_center = text.length/2
    i = 0
    text.chars.each do |char|
      board[center.first][center.last - char_center + i] = char
      i+=1
    end
  end

  def create_board
    @board = Array.new(length){ Array.new(width, '.') }
  end

end
```
You can’t change the `length`, or the `width` of the board or the board itself after initialization, so I have made them readable only.
Let’s walk through the code.

*  `center` – will calculate center points of the created Board;
*  `print_text` – will print the given text in the middle of the Board;
*  `create_board` – will create the Board and fill it with `“.”` to show this later on the screen.
Did you notice that I used a `block` to create an array, instead of `Array.new (length, Array.new(width, '.'))`?
At first sight the lines looks similar to each other, but if we look under the hood, you will notice that the block creates array each time, so `array[0].object_id` won’t be the same as: `array[1].object_id`.
And without the `block`, arrays will be identical.
``` ruby
pry(main)> array = Array.new(length){ Array.new(width, '.') }
 => [[".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."]]
pry(main)> array[0].object_id
 => 5689040
pry(main)> array[1].object_id
 => 5689000
```
``` ruby
pry(main)> array2 = Array.new(length, Array.new(width, '.'))
=> [[".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
 [".", ".", ".", ".", ".", ".", ".", ".", ".", "."]]
pry(main)> array2[0].object_id
=> 14755060
pry(main)> array2[1].object_id
=> 14755060
```

If make changes in the first line, this will immediately lead to changes in another.

## THE SNAKE

After you have created a board sample, it is time to create your ‘hero’! Here is the file to set the requirements for the snake and to tests your future snake `snake_spec.rb`
``` ruby
require 'spec_helper'
describe Snake do
  let(:snake){Snake.new(4,4)}
  describe "#new" do
    let(:snake){Snake.new(4,4)}
    it "snake is an array of body parts" do
      expect(snake.parts).to be_kind_of(Array)
      expect(snake.parts.size).to be_eql(4)
    end
    it "initializes snake head position" do
      expect(snake.parts.first).not_to be_nil
      expect(snake.parts.first).to be_kind_of(Array)
      expect(snake.parts.first.size).to be_eql(2)
      expect(snake.parts.first.first).to be_kind_of(Integer)
      expect(snake.parts.first.last).to be_kind_of(Integer)
    end
    it "initializes snake length" do
      expect(snake.size).to be_eql(4)
    end
    it "initializes snake direction" do
      expect(snake.direction).to be_eql(:left)
    end
  end

  it "#step should add one part and remove the last one from the snake" do
    old_snake = snake
      new_head = [snake.parts.first.first,snake.parts.first.last]
      old_snake.parts.unshift(new_head).pop
    snake.step
    expect(snake.parts).to be_eql(old_snake.parts)
  end

  it "#turn should change snake's direction" do
    snake.turn('w')
    expect(snake.direction).to eql(:up)
    snake.turn('a')
    expect(snake.direction).to eql(:left)
    snake.turn('s')
    expect(snake.direction).to eql(:down)
    snake.turn('d')
    expect(snake.direction).to eql(:right)
  end

  it "#update_head updates snake's head position if snake mets wall" do
    snake_head = snake.parts.first
    snake_head[0] = 2
    snake.update_head(0, 2)
    expect(snake.parts.first).to be_eql(snake_head)
  end

  it "#increase increases snake after food being eaten" do
    expect{snake.increase}.to change{snake.size}.from(4).to(5)
    expect{snake.increase}.to change{snake.parts.length}.from(5).to(6)
  end

end
```
As you can see, I want the `Snake` to be an array of ‘parts’, which means a small `array` of coordinates.
Let me explain this. Let’s draw our Snake as an array:
``` plain
.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .
.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .

.     .   [2,4] [3,4] [4,4] [5,4]   .     .     .

.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .
```
Now, if you need to move the Snake or change its direction, you can manage those blocks. You can add a part to the head and remove the last part from the tail. Or if the Snake eats the food block, you can just add it to the tail as well!
Turning the Snake is quite simple. You can add block in any direction from the current head block and remove the Snake’s last tail element. The Snake can be moved by one part in any direction.
``` plain
.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .
.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .

.     .   [2,4] [3,4] [4,4]   .     .     .     .

.     .   [2,5]   .     .     .     .     .     .

.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .

.     .     .     .     .     .     .     .     .
```
You will now need to create the Snake part with new coordinates, taking blocks from the head and changing its positions depending on the direction. Then, you can use `parts.unshift(new_head)` to add the new block to the beginning and `parts.pop` to remove the last one from the array.
If the snake eats ‘food’, you will create another part at the end of the Snake and update its size. If the snake meets the wall, you can simply move it to the other wall by changing its head coordinates.

``` ruby
class Snake
  attr_reader :size, :direction, :position, :parts
  def initialize(max_x, max_y)
    @size = 4
    @direction = :left
    @parts = []
    set_start_position(max_x, max_y)
    create_snake
  end

  def create_snake
    size.times do |iteration|
      @parts &lt;&lt; [position[0], position[1]+iteration]
    end
  end

  def head
    parts.first
  end

  def body
    parts[1..parts.length-1]
  end

  def set_start_position(max_x, max_y)
    @position = [Random.rand(0..max_x-1), Random.rand(0..max_y-1)]
  end

  def increase
    @size += 1
    @parts &lt;&lt; parts.last
  end

  def update_head(idx, value)
    @parts.first[idx] = value
  end

  def turn(key_code)
    @direction = case key_code.chr
    when 'w' || 'W'
      :up
    when 's' || 'S'
      :down
    when 'a' || 'A'
      :left
    when 'd' || 'D'
      :right
    else
      direction
    end
  end

  def step
    new_head = [head.first,head.last]
    case direction
    when :left
      new_head[1] -= 1
    when :right
      new_head[1] += 1
    when :up
      new_head[0] -= 1
    when :down
      new_head[0] += 1
    end
    parts.unshift(new_head)
    parts.pop
  end
end
```

Let’s walk through the code.

*  `initialize` – creates start parameters for the Snake, sets start position and creates the Snake.
*  `create_snake` – creates Snake, using size variable to define Snake’s length.
*  `head` – returns head part of Snake
*  `body` – returns all other parts, that you can call as ‘body’
*  `set_start_position` – randomly set start position of the Snake
*  `update_head` – updates head, if snake meet wall
*  `increase` – increases snake’s size, if the Snake eats food
*  `turn` – changes Snake’s direction
*  `step` – moves Snake’s each iteration

Now your Snake needs to eat something. Let’s write the `Food` object!

## FEEDING THE SNAKE

Food is a small object, that has only two coordinates, it will be reinitialized the moment after the Snake will eats it.
Let me describe it, using tests:
``` ruby
require 'spec_helper'
describe Food do
  let(:food_item){ Food.new(25, 25) }
  describe "#new" do
    it "initializes food item with start coords" do
      expect(food_item).not_to be_nil
      expect(food_item.x).not_to be_nil
      expect(food_item.y).not_to be_nil
    end
  end

  it "#coordinates returns array of food's coords" do
    expect(food_item.coordinates).to eq([food_item.x, food_item.y])
  end
end
```
Later, when the Snake’s head coordinates are over a Food coordinates, the game will show that the Snake ate the food. The snake will then increase in size and the Food object will reinitialize. That’s why the Food should be randomly generated.
``` ruby
class Food
  attr_reader :x, :y

  def initialize(board_max_x, board_max_y)
    @x = Random.rand(board_max_x-1)
    @y = Random.rand(board_max_y-1)
  end

  def coordinates
    [x,y]
  end
end
```
What will happen, if the Snake chooses to eat itself? You will need to create some errors for this case.

## THROWING ERROR

We can create different errors for different cases. For example, the Snake can meet walls sometimes, through which it could go through or which it could eat. If you would like to create some blocks, it may randomly appear on the Board and the Snake will smash into them. For this situations you need to create some errors.
I created `lib/errors/ate_itself_error.rb` file for these situations, such as The Snake eating itself.
It easily creates a new error class to determine the situation.
``` ruby
class AteItselfError < StandardError;
end
```
You will use it later in our `Game` class.

## THE GAME MECHANICS

Now it’s time to write the mechanics for the Game.
I have created a list of requirements, excluding the ones that show our information at the terminal.
`spec/game_spec.rb`:
``` ruby
require 'spec_helper'
describe Game do
  let(:new_game) {Game.new}
  describe "#new" do
    it "initializes game" do
      expect(new_game.gameboard).to be_kind_of(Board)
      expect(new_game.snake).to be_kind_of(Snake)
      expect(new_game.food).to be_kind_of(Food)
    end
  end

  it "#check_snake_position checks all checks successfully" do
    expect{new_game.check_snake_position}.to_not raise_error(AteItselfError)
    expect{new_game.check_snake_position}.to_not change{new_game.snake.body}
  end

  it "#check_if_snake_ate_itself" do
    new_game.snake.parts[0] = new_game.snake.parts.last
    expect{new_game.check_if_snake_ate_itself}.to raise_error(AteItselfError)
    expect{new_game.check_snake_position}.to raise_error(AteItselfError)
  end

  it "#check_if_snake_met_wall" do
    new_game.snake.parts[0][1] = new_game.gameboard.width
    expect{new_game.check_if_snake_met_wall}.to change{new_game.snake.parts[0][1]}.from(new_game.gameboard.width).to(0)
    new_game.snake.parts[0][1] = new_game.gameboard.width
    expect{new_game.check_snake_position}.to change{new_game.snake.parts[0][1]}.from(new_game.gameboard.width).to(0)
  end

  it "#check_if_snake_ate_food" do
    new_game.snake.parts[0] = new_game.food.coordinates
    expect{new_game.check_if_snake_ate_food}.to change{new_game.snake.size}.from(4).to(5)
    new_game.snake.parts[0] = new_game.food.coordinates
    expect{new_game.check_snake_position}.to change{new_game.snake.size}.from(5).to(6)
  end

  it "#compares pressed key" do
    expect(new_game.compare_key(65, 'a')).to be_truthy
    expect(new_game.compare_key(65, 'A')).to be_truthy
    expect(new_game.compare_key(65, 'Q')).to be_falsey
  end

  it "#execute_action quit on Q" do
    expect(new_game.execute_action('q'.ord)).to eql(false)
  end

  it "#execute_action turn on a" do
    expect{new_game.execute_action('d'.ord)}.to change{new_game.snake.direction}.from(:left).to(:right)
    expect(new_game.execute_action('d'.ord)).not_to be_nil
  end
end
```
So, now you have identified that your game will create the `Snake`, the `Board` and the `Food` object for you. Then it will be able to check Snake’s position. Checking the Snake’s positions consists of a few steps – to check, if the Snake has eaten itself or not, to check if the Snake has met at wall and to check, if the Snake has eaten food.
Our game must be able to get a key from the keyboard and compare receiver’s value with some char that will turn the Snake or make some game actions. Comparing it, should execute some actions. For example, quit game on `Q` or turn snake on `d`.
Now it’s time to see how this Ruby code will work!
``` ruby
require 'io/console'
class Game
  attr_reader :gameboard, :snake, :food
  def initialize(max_x=11, max_y=11)
    @gameboard = Board.new(max_x, max_y)
    @snake = Snake.new(gameboard.width, gameboard.length)
    @food = Food.new(gameboard.width, gameboard.length)
  end

  def print_board
    system('clear')
    puts "Your size is: #{snake.size} |  [Q]uit"
    gameboard.board.each do
      |line| puts line.each{|item| item}.join(" ")
    end
  end

  def draw_food_and_snake
    gameboard.create_board
    @gameboard.board[food.x][food.y] = 'o'
    snake.parts.each do |part|
      @gameboard.board[part.first][part.last] = 'x'
    end
    print_board
  end

  def show_message(text)
    gameboard.create_board
    gameboard.print_text(text)
    print_board
  end

  def show_start_screen
    start = false
    while start == false
      show_message("[S]tart")
      key = GetKey.getkey
      sleep(0.5)
      if key &amp;&amp; compare_key(key, 's')
        start = true
      end
    end
  end

  def check_snake_position
    check_if_snake_met_wall
    check_if_snake_ate_food
    check_if_snake_ate_itself
  end

  def check_if_snake_ate_itself
    if snake.body.include? snake.head
      raise AteItselfError
    end
  end

  def check_if_snake_met_wall
    snake.update_head(1,0) if snake.head[1] &gt; gameboard.width-1
    snake.update_head(1, gameboard.width-1) if snake.head[1]  gameboard.length-1
    snake.update_head(0, gameboard.length-1) if snake.head[0] &lt; 0
  end

  def check_if_snake_ate_food
    if snake.head[0] == food.x &amp;&amp; snake.head[1] == food.y
      snake.increase
      @food = Food.new(gameboard.width, gameboard.length)
    end
  end

  def start
    show_start_screen
    begin
      tick
    rescue AteItselfError
      show_message("Game over")
    end
  end


  def tick
    in_game = true
    while in_game
      draw_food_and_snake
      sleep(0.1)
      if key = GetKey.getkey
        in_game = execute_action(key)
      end
      snake.step
      check_snake_position
    end
    show_message("Game quit")
  end

  def execute_action key
    return false if compare_key(key, 'q')
    snake.turn(key)
  end

  def compare_key(key, char)
    key.chr == char.downcase || key.chr == char.upcase
  end
end
```

Let’s walk through the code.

*  `initialize` – creates the `Snake`, the `Board` and the `Food` objects;;
*  `tick` – the main method that re-renders the Board and all objects in it, checks position, sets direction each 0.1 second. This value can be changed to increase or decrease speed of the game;
*  `print_board` – prints the game Board on the screen for each tick of time;
*  `draw_food_and_snake` – clears Board array and sets food and snake on it;
*  `show_message` – draws message on our Board;
*  `show_start_screen` – draws start screen;
*  `check_if_snake_ate_itself` – ends game, if the Snake ate itself;
*  `check_if_snake_met_wall` – updates head, if The Snake met the wall;
*  `check_if_snake_ate_food` – increases Snake’s size, if the Snake eats food and re-creates food;
*  `check_snake_position` – checks if snake met one of the positions above
*  `start` – method, which runs our game. Launches tick and ends game, if any error appears in the game (example: `AteItselfError`);
*  `execute_action` – executes an action on `keypress` by given keys;
*  `compare_key` – compares the given key and receives one from `stdin`.

## GETTING KEYS PRESSED

You can see `GetKey` module, that I haven’t told you about. At the beginning of my development, I got into a situation that almost made me give up.
I tried `STDIN.read_nonblock`, `STDIN.getc`, `gets` and other solutions, but none of them gave me the expected result. Fortunately, I found [this question](http://stackoverflow.com/questions/946738/detect-key-press-non-blocking-w-o-getc-gets-in-ruby), which had a solution to my problem. Now we don’t wait until the key is pressed, but continue rendering our game with the movement of the Snake. `GetKey` module is listed under `lib/get_key.rb`

## LET’S PLAY!

Finally, you can write the last Ruby file that will start our Game – `start.rb`
``` ruby
Dir[File.expand_path('lib/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
Dir[File.expand_path('lib/errors/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
require 'pry'

game = Game.new
game.start
```
You should be requiring all game files as you did in `spec_helper` and creating a new game object using `Game.new`. `game.start` that will start your game.
You should see something like this:

[{% img /images/ruby_snake/abf5d12ac93fe44c9e8b8051fddf8ac3dd60f4d1.png %}](https://asciinema.org/a/a71jakx5dwtp4jy2962ef3sw8)


## CONCLUSION

We have created a good base for a simple Snake Game that now can be extended with different features. I’ve played a bit with code and found that it is easy to create:

*  a common Snake Game with walls:
{% img /images/ruby_snake/Screenshot-from-2016-08-18-012212.png %}

*  Snake Game for two players and for playing with computer opponent:
{% img /images/ruby_snake/Screenshot-from-2016-08-18-013530.png %}

*  Snake Game with different ‘enemies’ that can hurt you:
{% img /images/ruby_snake/Screenshot-from-2016-08-18-012806.png %}

*  and many more...

[sources are here](https://github.com/AKovtunov/ruby_snake)

<h1 align="center">Enjoy the game!</h1>
