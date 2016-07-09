# Quaternion class
# MIT License

def Quaternion *args
  if args[0].nil?
    Quaternion.new
  elsif args[0].is_a? Quaternion
    args[0]
  elsif args[0].is_a? Complex
    if args[1].nil?
      Quaternion.new args[0].real, args[0].imag
    elsif args[1].is_a? Complex
      Quaternion.new args[0].real, args[0].imag, args[1].real, args[1].imag
    else
      raise TypeError.new "invalid argument"
    end
  elsif args[0].is_a? Numeric
    if args[1]
      if args[1].is_a? Vector
        Quaternion.new args[0], *args[1]
      else
        Quaternion.new *args
      end
    end
  elsif args[0].is_a? Array
    Quaternion.new *args[0]
  else
    raise TypeError.new "invalid argument"
  end
end

class Quaternion < Numeric
  attr_accessor :t0, :t1, :t2, :t3

  def initialize t0=0, t1=0, t2=0, t3=0
    @t0 = t0
    @t1 = t1
    @t2 = t2
    @t3 = t3
  end

  # imaginary constants

  I = self.new 0, 1, 0, 0
  J = self.new 0, 0, 1, 0
  K = self.new 0, 0, 0, 1

  # override methods from Numeric

  def % other
    if other.is_a? Quaternion
      raise "invalid operation"
    else
      Quaternion.new @t0%other, @t1%other, @t2%other, @t3%other
    end
  end

  def + other
    if other.is_a? Quaternion
      Quaternion.new @t0+other.t0, @t1+other.t1, @t2+other.t2, @t3+other.t3
    elsif other.is_a? Complex
      Quaternion.new @t0+other.real, @t1+other.imag, @t2, @t3
    elsif other.is_a? Numeric
      Quaternion.new @t0+other, @t1, @t2, @t3
    else
      super
    end
  end

  def - other
    if other.is_a? Quaternion
      Quaternion.new @t0-other.t0, @t1-other.t1, @t2-other.t2, @t3-other.t3
    elsif other.is_a? Complex
      Quaternion.new @t0-other.real, @t1-other.imag, @t2, @t3
    elsif other.is_a? Numeric
      Quaternion.new @t0-other, @t1, @t2, @t3
    else
      super
    end
  end

  def * other
    if other.is_a? Quaternion
      Quaternion.new(
        @t0*other.t0 - @t1*other.t1 - @t2*other.t2 - @t3*other.t3,
        @t0*other.t1 + @t1*other.t0 + @t2*other.t3 - @t3*other.t2,
        @t0*other.t2 - @t1*other.t3 + @t2*other.t0 + @t3*other.t1,
        @t0*other.t3 + @t1*other.t2 - @t2*other.t1 + @t3*other.t0
      )
    elsif other.is_a? Complex
      Quaternion.new(
        @t0*other.real - @t1*other.imag,
        @t0*other.imag + @t1*other.real,
        @t2*other.real + @t3*other.imag,
        -@t2*other.imag + @t3*other.real
      )
    elsif other.is_a? Numeric
      Quaternion.new @t0*other, @t1*other, @t2*other, @t3*other
    else
      super
    end
  end

  def / other
    if other.is_a? Quaternion
      self * other.inverse
    else
      self * (1/other)
    end
  end

  def == other
    if other.is_a? Quaternion
      @t0 == other.t0 and @t1 == other.t1 and @t2 == other.t2 and @t3 == other.t3
    elsif other.is_a? Complex
      @t2 == 0 and @t3 == 0 and @t0 == other.real and @t1 == other.imag
    elsif other.is_a? Numeric
      @t1 == 0 and @t2 == 0 and @t3 == 0 and @t0 == other
    else
      nil
    end
  end

  def coerce other
    if other.is_a? Quaternion
      [self, other]
    elsif other.is_a? Numeric
      [self, Quaternion(other)]
    else
      super
    end
  end

  def integer?
    @t0.integer? and @t1.integer? and @t2.integer? and @t3.integer?
  end

  def real?
    false
  end

  def to_c
    if @t2 == 0 and @t3 == 0
      Complex[@t0, @t1]
    else
      raise RangeError.new "can't convert #{self.to_s} into Complex"
    end
  end

  def to_f
    if @t1 == 0 and @t2 == 0 and @t3 == 0
      @t1.to_f
    else
      raise RangeError.new "can't convert #{self.to_s} into Float"
    end
  end

  def to_i
    if @t1 == 0 and @t2 == 0 and @t3 == 0
      @t1.to_i
    else
      raise RangeError.new "can't convert #{self.to_s} into Integer"
    end
  end

  def to_s
    "#{@t0}#{symbolize @t1}i#{symbolize @t2}j#{symbolize @t3}k"
  end

  def inspect
    "(#{self.to_s})"
  end

  # quaternion functions

  def dot other
    if other.is_a? Quaternion
      @t0*other.t0 + @t1*other.t1 + @t2*other.t2 + @t3*other.t3
    elsif other.is_a? Complex
      @t0*other.real + @t1*other.imag
    elsif other.is_a? Numeric
      @t0*other
    else
      raise TypeError.new "invalid parameter type"
    end
  end

  def conjugate
    Quaternion.new @t0, -@t1, -@t2, -@t3
  end
  alias conj conjugate
  def conjugate!
    @t1 = -@t1
    @t2 = -@t2
    @t3 = -@t3
    self
  end
  alias conj! conjugate!

  def norm2
    @t0**2 + @t1**2 + @t2**2 + @t3**2
  end
  alias abs2 norm2

  def norm
    Math::sqrt(self.norm2)
  end
  alias abs norm
  alias length norm

  def inverse
    # suppressing object generation
    # original: self.conjugate / self.norm2
    n2 = self.norm2
    Quaternion.new @t0/n2, -@t1/n2, -@t2/n2, -@t3/n2
  end
  def inverse!
    n2 = self.norm2
    @t0 = -@t0/n2
    @t1 = -@t1/n2
    @t2 = -@t2/n2
    @t3 = -@t3/n2
    self
  end

  def negate
    Quaternion.new -@t0, -@t1, -@t2, -@t3
  end
  def negate!
    @t0 = -@t0
    @t1 = -@t1
    @t2 = -@t2
    @t3 = -@t3
    self
  end

  def normalize
    self / self.norm
  end
  alias unify normalize
  def normalize!
    n = self.norm
    @t0 /= n
    @t1 /= n
    @t2 /= n
    @t3 /= n
    self
  end
  alias unify! normalize!

  # accessors

  alias real t0
  alias w t0
  def imag
    Vector[@t1, @t2, @t3]
  end
  alias imaginary imag

  alias imag0 t1
  alias i t1

  alias imag1 t2
  alias j t2

  alias imag2 t3
  alias k t3

  # support methods

  private
  def symbolize num
    if num >= 0
      "+#{num}"
    else
      num
    end
  end

  # generators

  class << self
    def [] *args
      Quaternion(*args)
    end

    def rect t0, t1=0
      self.new t0, t1
    end
    alias rectanglar rect

    def quat *args
      self.new *args
    end

    def ypr y=0, p=0, r=0
      y *= 0.5
      p *= 0.5
      r *= 0.5
      sy = Math.sin(y)
      cy = Math.cos(y)
      sx = Math.sin(p)
      cx = Math.cos(p)
      sz = Math.sin(r)
      cz = Math.cos(r)
      self.new(
        cz * cx * cy + sz * sx * sy,
        cz * sx * cy + sz * cx * sy,
        sz * cx * cy - cz * sx * sy,
        cz * cx * sy - sz * sx * cy
      )
    end
  end
end
