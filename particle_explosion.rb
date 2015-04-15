require 'gosu'
require 'matrix'
require 'texplay'

GravityVector = Vector[0.0, -1.0]



class Particle
  attr_reader :heat, :position, :velocity
  def self.create(velocity)
    self.new(1, Vector[0, 0], velocity)
  end

  def self.from(options={})
    speed = options.fetch(:speed)
    direction = options.fetch(:direction)
    heat = options.fetch(:heat, 1.0)
    self.new(heat, Vector[0, 0], Vector[Math.cos(direction) * speed, Math.sin(direction) * speed])
  end
  
  def initialize(heat, position, velocity)
    @heat = heat
    @position = position
    @velocity = velocity
  end

  def speed
    @velocity.magnitude
  end

  def heading
    Math.atan2(@velocity[1], @velocity[0])
  end

  def succ    
    self.class.new(([@heat - 0.00001, 0].max) ** 1.2, @position + @velocity, @velocity + GravityVector)
  end
end

class ParticleExplosion
  attr_reader :particles
  def initialize
    rnd = Random.new
    @particles = (0..100).collect do |each|
      Particle.from(:speed => rnd.rand(0..20.0), :direction => rnd.rand(-Math::PI * 0.1..Math::PI * 1.1), :heat => rnd.rand(0.9..1.0))
    end
  end

  def update
    @particles = @particles.collect(&:succ)
  end

end

class Woom
  def initialize
    @ticks = 360
  end
  
  def update
    @ticks -= 1
  end

  def draw_on(canvas)
    if @ticks > 0
      canvas.draw_centered_text((@ticks / 2).to_s)
    end
  end
end

class ParticleExplosionWindow < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Particle Explosion"
    @simulation = nil
    @font = Gosu::Font.new(self, "helvetica", 40)
    p [width, height]
    @canvas = TexPlay.create_image(self, width, height)
    @tick_count = 0
  end

  def update
    if !@simulation
      return
    end
    @tick_count += 1
    return if @tick_count < 2
    @tick_count = 0
    @simulation.update
  end

  def draw
    if !@simulation
      return
    end
    #@simulation.draw_on(self)
    canvas_dup = @canvas.dup
    particles = @simulation.particles
    canvas_dup.paint {
      particles.each do |each| 
        pixel each.position[0] + width / 2, -each.position[1] + height / 2, :color => [[each.heat * 10, 1].min, each.heat, each.heat * 0.7, 1]
      end
    }

    canvas_dup.draw(0, 0, 1)
  end

  def draw_centered_text(string)
    @font.draw(string, (width / 2) - @font.text_width(string) / 2, (height / 2) - (@font.height / 2), 0)
  end

  def draw_particles(particles)
    @canvas.paint {
      particles.each do |position, rgba|
        pixel position[0] + (width / 2), -position[1] + (height / 2), :color => rgba
      end
    }
  end

  def button_down(id)
    case id
    when Gosu::KbSpace
      @simulation = ParticleExplosion.new
    end
  end
end

def run!
  window = ParticleExplosionWindow.new
  puts window.update_interval
  window.show
end

run! if __FILE__ == $0
  
