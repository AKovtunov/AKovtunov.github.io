---
layout: post
title: "Different sides of Ruby development: OpenGL"
date: 2017-04-24 12:03:59 +0200
comments: true
categories: "ruby, opengl, gamedev, game"
---

> This is a copy of my [original post for Diatom Enterprises](http://www.diatomenterprises.com/different-sides-of-ruby-development-opengl/)


When I’m trying to take a break from web development, I like to build something new and uncommon in Ruby programming. Ruby is typically known for web services, APIs and other web-related development. But with some time, you can build many other types of software.
Different sides of Ruby development: OpenGL

{% img /images/ruby_opengl/blan_eeeeee1.jpg %}

After creating , I started researching Ruby applications that use 3D graphics. I found a nice library, [OpenGL for Ruby](https://github.com/larskanis/opengl), and created a few samples with it. At first, it can be difficult to understand everything, but let’s see what can we do!

<!--more-->

To start working with `OpenGL` for Ruby, we only need two gems:
`Gemfile.rb`:

``` ruby
source "https://rubygems.org"
gem "gosu"
gem "opengl"
```

I chose [gosu](https://github.com/tianon/gosu) because it provides good functionality to work with windows, players and partial rendering of window objects.

## LET’S CREATE SOMETHING SIMPLE!

Sometimes it’s hard to imagine how everything should look in 3D, so for the first step, I chose to draw an axis instead of a simple cube.
This is a good way to see how our coordinates lie on the three-dimensional grid. Also, we will set the color of the lines to define where the `x`, `y` and `z` coordinates are.
I suggest that you separate objects into different classes that will stay under the `objects/` directory. So `media/axis.rb` will contain:
``` ruby
class Axis
  attr_reader :x_width, :y_width, :z_width

  def initialize(x_width, y_width, z_width)
    @x_width = x_width
    @y_width = y_width
    @z_width = z_width
  end

  def self.draw(x_width, y_width, z_width)
    object = new(x_width, y_width, z_width)
    object.draw
  end

  def draw
    glBegin(GL_LINES)
      glColor3d(1, 0, 0)
      glVertex3d(0, 0, 0)
      glVertex3d(x_width, 0, 0)
      glColor3d(0, 1, 0)
      glVertex3d(0, 0, 0)
      glVertex3d(0, y_width, 0)
      glColor3d(0, 0, 1)
      glVertex3d(0, 0, 0)
      glVertex3d(0, 0, z_width)
    glEnd
  end
end
```

All the OpenGL magic happens in the draw action. `glBegin` and `glEnd` works like a ruby block where in argument you need to send the type of object that you want to draw in the argument. You can find all the types in the [official documentation](https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glBegin.xml).
Inside this block you set the lines and their color. This sets the color for all the lines that you will draw after method `glColor3d`. There are lots of different implementations of the `glColor` method that differ only by the type of argument.`glColor3d` takes arguments in `GLdouble`, `glColor3f`, `GLfloat`, etc. `glColor3d` takes three arguments – red, green and blue values. `glColor4*` can also take an alpha value.
To draw a line, you need to set two points, and OpenGL will draw a line between them. To do this, you need to call `glVertex`. You can pass two to four arguments of different types, depending on the method you are trying to call. In our case, we are sending the `x`, `y` and `z` coordinates of our future points. You can set as many lines in your `glBegin…glEnd` block as you wish. In my example, I’m drawing lines from the beginning of the axis (x = 0, y = 0, z = 0) to (x = `x_width`, y = `y_width`, z = `z_width`) in pixels.

``` ruby
require 'opengl'
require 'glu'
require 'gosu'
Dir["objects/*"].each {|file| require_relative file }
include Gl, Glu

class Window &lt; Gosu::Window

  def initialize
    super 800, 600
    self.caption = "Diatom's OpenGL Tutorial"
  end

  def update
  end

  def draw
    gl do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      Axis.draw(100, 100, 100)
    end
  end

  def button_down(id)
    exit if id == Gosu::KbEscape
  end
end

Window.new.show
```

`glClear` clears buffers to preset values. After that we call `Axis.draw` to draw our axis.

{% img /images/ruby_opengl/diatom_opengl-4.jpg %}

As you can see, we can’t find an `y` axis because there is a frame border in its place. So if you want, you can set start of the line from `(x = 1)` instead of `(x = 0)`.

{% img /images/ruby_opengl/diatom_opengl-5.jpg %}

Here we see a problem: what if we want to draw a set different objects, but not from the top left corner? What if we want to move the center of the axes?

##MOVING THE CENTER OF THE AXES

To move the center of the axes, we can use the `glTranslate` method. It multiplies the current matrix by a translation matrix and produces a translation by x, y, z. All the objects after the `glTranslate` method will be drawn depending on those coordinates. To work with both translated and normal coordinates, we need to use the `glPushMatrix` and `glPopMatrix` methods, which will save the previous matrix and restore it. `glTranslate` produces different methods – `glTranslated(x, y, z)`, `glTranslatef(x, y, z)` etc. – where `x`, `y` and `z` are the coordinates of a translation vector.
Let’s update our code using this method.

``` ruby
def draw
 gl do
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
   glPushMatrix
     glTranslated(width/2, height/2, 0)
     Axis.draw(100, 100, 100)
   glPopMatrix
 end
end
```

{% img /images/ruby_opengl/diatom_opengl-6.jpg %}

As we can now see, our axis moved to the center of our screen. To see the difference and how `glPushMatrix` and `glPopMatrix` work, let’s add the previous axis too.

``` ruby
def draw
  gl do
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glPushMatrix
      glTranslated(width/2, height/2, 0)
      Axis.draw(100, 100, 100)
    glPopMatrix

    glEnable(GL_LINE_STIPPLE)
    glLineStipple(2,0x00FF)

    Axis.draw(100, 100, 100)
    glDisable(GL_LINE_STIPPLE)
  end
end
```

{% img /images/ruby_opengl/diatom_opengl-3.jpg %}

As you can see, the previous axis was drawn on the (0, 0, 0) coordinates with the stippled lines without any change to `axis.rb` or its coordinates.
It seems like we forgot about the z coordinate that we can’t see on our flat screen. To take a look at it, we need to use a viewpoint.

## GETTING INTO THE REAL 3D WORLD

At first, I suggest that you build another object on our scene – a cube. It will help us to see the difference between the angles of our viewpoint.
To draw it, we can use `GL_QUADS`. Each of the four points defines a Quad, so to make a cube we need six Quads = 24 points.
`objects/cube.rb`:

``` ruby
require 'pry'
class Cube
  attr_reader :x_width, :y_width, :z_width, :mode, :mode_face

  def initialize(x_width, y_width, z_width, mode_face, mode)
    @x_width = x_width
    @y_width = y_width
    @z_width = z_width
    @mode = mode
    @mode_face = mode_face
  end

  def self.draw(x_width, y_width, z_width, mode_face = GL_FRONT_AND_BACK, mode = GL_FILL)
    object = new(x_width, y_width, z_width, mode_face, mode)
    object.draw
  end

  def draw
    glPolygonMode(mode_face, mode);
    glBegin(GL_QUADS)
      #yx
      glColor3d(1, 0, 0)
      glVertex3d(0, 0, 0)
      glVertex3d(x_width, 0, 0)
      glVertex3d(x_width, y_width, 0)
      glVertex3d(0, y_width, 0)
      #yz
      glColor3d(0, 1, 0)
      glVertex3d(0, y_width, 0)
      glVertex3d(0, 0, 0)
      glVertex3d(0, 0, z_width)
      glVertex3d(0, y_width, z_width)
      #zx
      glColor3d(0, 0, 1)
      glVertex3d(0, 0, z_width)
      glVertex3d(0, 0, 0)
      glVertex3d(x_width, 0, 0)
      glVertex3d(x_width, 0, z_width)
      #z -> yx
      glColor3d(1, 0, 0)
      glVertex3d(0, 0, z_width)
      glVertex3d(x_width, 0, z_width)
      glVertex3d(x_width, y_width, z_width)
      glVertex3d(0, y_width, z_width)
      #x -> yz
      glColor3d(0, 1, 0)
      glVertex3d(x_width, y_width, 0)
      glVertex3d(x_width, 0, 0)
      glVertex3d(x_width, 0, z_width)
      glVertex3d(x_width, y_width, z_width)
      #y -> zx
      glColor3d(0, 0, 1)
      glVertex3d(0, y_width, z_width)
      glVertex3d(0, y_width, 0)
      glVertex3d(x_width, y_width, 0)
      glVertex3d(x_width, y_width, z_width)
    glEnd
  end
end

```

I’ve added two new variables – arguments for `glPolygonMode` that set a `rasterization` mode. The arguments are face (front, back) and mode (`GL_POINT`, `GL_LINE`, `GL_FILL`).
Let’s also update our axes and move code that defines their line types inside.

`objects/axis.rb`:

``` ruby
class Axis
  attr_reader :x_width, :y_width, :z_width, :stipple

  def initialize(x_width, y_width, z_width, stipple = false)
    @x_width = x_width
    @y_width = y_width
    @z_width = z_width
    @stipple = stipple
  end

  def self.draw(x_width, y_width, z_width, stipple = false)
    object = new(x_width, y_width, z_width, stipple)
    object.draw
  end

  def draw
    if stipple
      glEnable(GL_LINE_STIPPLE)
      glLineStipple(2,0x00FF)
    end
    glBegin(GL_LINES)
      ...
    glEnd
    glDisable(GL_LINE_STIPPLE) if stipple
  end
end

```

Let’s update our code to use our new cubes.

``` ruby
def draw
  gl do
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glPushMatrix
      glTranslated(width/2, height/2, 0)
      Axis.draw(100, 100, 100)
      Cube.draw(50, 50, 50, GL_FRONT_AND_BACK, GL_LINE)
    glPopMatrix

    Cube.draw(50, 50, 50, GL_FRONT_AND_BACK, GL_LINE)

    Axis.draw(100, 100, 100, true)
  end
end
```

{% img /images/ruby_opengl/diatom_opengl-9.jpg %}

Looks clear, doesn’t it?
To add perspective, we need to use the `gluPerspective` method, which is used to set up a perspective projection. It’s done once to set up how the scene will be rendered. If `gluPerspective` is used, the perspective correction will happen while rendering. The arguments are angle of view, aspect ratio, z-near and z-far.

{% img /images/ruby_opengl/Untitled-drawing-1.jpg %}

So, let’s add perspective to our application.

``` ruby
def draw
  gl do
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glMatrixMode(GL_PROJECTION)
  	glLoadIdentity()
  	gluPerspective(130, width.to_f/height, 0, 500)
  	glMatrixMode(GL_MODELVIEW)
  	glLoadIdentity()

    glPushMatrix
      glTranslated(width/2, height/2, 0)
      Axis.draw(100, 100, 100)
      Cube.draw(50, 50, 50, GL_FRONT_AND_BACK, GL_LINE)
    glPopMatrix

    Cube.draw(50, 50, 50, GL_FRONT_AND_BACK, GL_LINE)

    Axis.draw(100, 100, 100, true)
  end
end
```
{% img /images/ruby_opengl/diatom_opengl-10.jpg %}

We can see that our field of view has been updated, and we can see only part of our (0, 0, 0) cube and axis. To see what `gluPerspective` really changes, let’s add a viewpoint.

To turn the player, OpenGL developers usually build a matrix of the view, load it and use later to turn the entire scene around the player. To simplify our code, we will create a ‘camera’ object that will help us look at the whole scene. To do this, we will use `gluLookAt`.

{% img /images/ruby_opengl/Untitled-123.jpg %}

If we don’t set `gluLookAt`, OpenGL will automatically set it to (x = 0, y = 0, z = 0). Looking at our screen, that will be equal to `gluLookAt(0, 0, 1, 0, 0, 0, 0, 1, 0)`. So, let’s set our `gluLookAt` properly, so we can see our scene.

``` ruby
glMatrixMode(GL_MODELVIEW)
glLoadIdentity()
gluLookAt(400, 400, 400, 0, 0, 0, 0, 1, 0)
```

`gluLookAt` sets our camera to point (x = 400, y = 400, z = 400) and looks at point (x = 0, y = 0, z = 0), three other coordinates of `up` vector that we will not touch for now.

{% img /images/ruby_opengl/diatom_opengl-12.jpg %}

Let’s play with gluPerspective a bit now.
`gluPerspective(130, width.to_f/height, 0.001, 225)`


s
