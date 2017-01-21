class Octonion < Quaternion
  attr_accessor :t4, :t5, :t6, :t7

  def initialize t0=0, t1=0, t2=0, t3=0, t4=0, t5=0, t6=0, t7=0
    @t0 = t0
    @t1 = t1
    @t2 = t2
    @t3 = t3
    @t4 = t4
    @t5 = t5
    @t6 = t6
    @t7 = t7
  end

  # imaginary constants

  R = E0 = self.new 1
  I = E1 = self.new 0, 1
  J = E2 = self.new 0, 0, 1
  K = E3 = self.new 0, 0, 0, 1
  L = E4 = self.new 0, 0, 0, 0, 1
  M = E5 = self.new 0, 0, 0, 0, 0, 1
  N = E6 = self.new 0, 0, 0, 0, 0, 0, 1
  O = E7 = self.new 0, 0, 0, 0, 0, 0, 0, 1

end
