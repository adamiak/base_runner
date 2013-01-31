# encoding: utf-8

require "bundler/setup"
require "gaminator"

$ww = 170
$hh = 45
$stop = false
$winner = ''
$rot = 0.03

class Game

    class TheEnd < Struct.new(:x, :y)
        def char
            "The end. The player on the "+$winner+" WON!"
        end
        def color
          Curses::COLOR_YELLOW
        end
    end

    class Base < Struct.new(:x, :y)
        def char
          "##"
        end

        def color
          Curses::COLOR_GREEN
        end
      end

    class Ufo
      def initialize(x, y, char)
          @x = x
          @y = y
          @char = char
          @dx = 0
          @dy = 0
      end

      attr_accessor :x
      attr_accessor :y
      attr_accessor :dx
      attr_accessor :dy
      attr_accessor :char

      def move
          @x += @dx/2.0
          @y += @dy/4.0

          if @x < 0
              @x = 0
              @dx *= -1
          end
          if @y < 0
              @y = 0
              @dy *= -1
          end
          if @x > $ww
              @x = $ww
              @dx *= -1
          end
          if @y > $hh
              @y = $hh
              @dy *= -1
          end
      end

        def color
          Curses::COLOR_WHITE
        end

    end

  class Ball
      def initialize(x, y, dx, dy)
          @x = x
          @y = y
          @dx = dx
          @dy = dy
      end

      attr_accessor :x
      attr_accessor :y
      attr_accessor :dx
      attr_accessor :dy

      def move
          @x += @dx
          @y += @dy/2

          if @x > $ww 
              @dx *= -1
              @x = $ww
          end

          if @y > $hh
              @dy *= -1
              @y = $hh
          end

          if @x < 0
              @dx *= -1
              @x = 0
          end

          if @y < 0
              @dy *= -1
              @y = 0
          end

      end

        def char
          "@"
        end
  end

  class BatVert < Struct.new(:x, :y)
        def char
          "#"
        end

        def color
          Curses::COLOR_RED
        end
      end

  class Bat
      def initialize(x, y, r, angle)
          @x_c =x
          @y_c = y
          @r = r
          @angle = angle
      end

      attr_accessor :angle

        def x
            @x_c + @r * Math.sin(@angle)
        end

        def y
            @y_c + (@r/2.0) * Math.cos(@angle)
        end

      def char
          '#'
      end

        def color
          Curses::COLOR_MAGENTA
        end

  end

  def initialize(width, height)
      restart
  end

  def restart
    $stop = false
    @ticks = 0
    @x_c = $ww/2
    @y_c = $hh/2

    @angle_start = 0.0
    @angle = @angle_start
    @bats_1 = []
    @bats_2 = []
    @bats_3 = []

    @bats_vert = []

    @by = 0
    while @by < ($hh/2)-4 do
        @bats_vert.push(BatVert.new(@x_c, @by))
        @by += 1
    end

    @by = $hh
    while @by > ($hh/2)+4 do
        @bats_vert.push(BatVert.new(@x_c, @by))
        @by -= 1
    end

    @ufo1 = Ufo.new(1,7, '>')
    @base1 = Base.new(1, 5)
    @ufo2 = Ufo.new($ww-1, $hh-7, '<')
    @base2 = Base.new($ww-10, $hh-5)
#    @balls = [
#        Ball.new(1.0, 1.0, 0.9, 0.3),
#        Ball.new(11.0, 1.0, 0.4, 0.7),
#        Ball.new(1.0, 21.0, -0.7, 0.9),
#        Ball.new(1.0, 1.0, 0.3, 0.7),
#        Ball.new(30.0, 30.0, -0.6, -0.7),
#    ]

    while @angle < @angle_start+Math::PI*2*(1.5/4.0) do
        @bats_1.push(Bat.new(@x_c, @y_c, 10.0, @angle))
        @angle += Math::PI/180.0
    end

    @angle_start = 1.0
    @angle = @angle_start
    while @angle < @angle_start+Math::PI*2*(2.0/4.0) do
        @bats_2.push(Bat.new(@x_c, @y_c, 28.0, @angle))
        @angle += Math::PI/180.0
    end

    @angle_start = 2.0
    @angle = @angle_start
    while @angle < @angle_start+Math::PI*2*(2.3/4.0) do
        @bats_3.push(Bat.new(@x_c, @y_c, 42.0, @angle))
        @angle += Math::PI/180.0
    end

    @score = 0
  end

  def objects
    res = @bats_1 + @bats_2 + @bats_3 + @bats_vert + [@ufo1, @ufo2, @base1, @base2] #@balls
    if $stop
        res.push(TheEnd.new($ww/2-20, $hh/2))
    end
    res
  end


  def input_map
    {
      ?j => :move_left2,
      ?l => :move_right2,
      ?i => :move_up2,
      ?k => :move_down2,

      ?a => :move_left1,
      ?d => :move_right1,
      ?w => :move_up1,
      ?s => :move_down1,

      ?q => :restart,
      ?` => :exit,
    }
  end

  def move_up2
      @ufo2.dy = -1
      @ufo2.dx = 0
  end
  def move_down2
      @ufo2.dy = 1
      @ufo2.dx = 0
  end
  def move_left2
      @ufo2.dx = -1
      @ufo2.dy = 0
  end
  def move_right2
      @ufo2.dx = 1
      @ufo2.dy = 0
  end

  def move_up1
      @ufo1.dy = -1
      @ufo1.dx = 0
  end
  def move_down1
      @ufo1.dy = 1
      @ufo1.dx = 0
  end
  def move_left1
      @ufo1.dx = -1
      @ufo1.dy = 0
  end
  def move_right1
      @ufo1.dx = 1
      @ufo1.dy = 0
  end

  def exit
    Kernel.exit
  end

  def speed_down
      @ufo.break = 3
  end

  def move_1
      @bats_1.each do |b|
          b.angle += $rot
      end
  end

  def move_2
      @bats_2.each do |b|
          b.angle -= $rot
      end
  end

  def move_3
      @bats_3.each do |b|
          b.angle += $rot
      end
  end

#  def move_clockwise
#      @l_bats.each { |b| b.angle += 0.1 }
#      @r_bats.each do |b| 
#        b.angle -= 0.1 
#          if b.angle <= 0 
#              b.angle = Math::PI * 2.0
#          end
#      end 
#  end

  def tick
      if $stop
          return
      end
#      move_clockwise
#        move_balls
        check_collisions
        check_bases
        move_1
        move_2
        move_3
        @ufo1.move
        @ufo2.move
  end
  def check_bases
      if (@base1.x-@ufo2.x).abs <= 2.0 and (@base1.y-@ufo2.y).abs <= 2.0
          $winner = 'RIGHT'
          $stop = true
          return
      end
      if (@base2.x-@ufo1.x).abs <= 2.0 and (@base2.y-@ufo1.y).abs <= 2.0
          $winner = 'LEFT'
          $stop = true
          return
      end
  end

  def check_collisions
      (@bats_1+@bats_2+@bats_3+@bats_vert).each do |bat|
          [@ufo1, @ufo2].each do |ufo|
              if (ufo.x-bat.x).abs <= 1.0 and (ufo.y-bat.y).abs <= 1.0
                  if ufo == @ufo1
                      $winner = 'RIGHT'
                  else
                      $winner = 'LEFT'
                  end
                  $stop = true
                  return
              end
          end
      end
    end

  def move_balls
      @balls.each do |b|
          b.move
      end
      (@bats_1+@bats_2+@bats_3).each do |bat|
          @balls.each do |ball|
              if (ball.x.round-bat.x.round).abs < 2 and (ball.y.round-bat.y.round).abs < 2
                  ball.dx *= -1
                  ball.dy *= -1
                  break
              end
          end
      end
  end

  def exit_message
    "Bye!"
  end

  def textbox_content
    "Move left player with WASD, Move right player with JKLI, restart with Q, exit with `"
  end

  def wait?
    false
  end

  def sleep_time
    0.005 
  end

end

Gaminator::Runner.new(Game, :rows => $hh+8, :cols => $ww+4).run
