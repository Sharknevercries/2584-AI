require "./feature"

class TupleNetwork
  def initialize(@patterns : Array(Feature))
  end

  def update(b : Board, value : Number)
    v = value / @patterns.size
    @patterns.each do |pattern|
      pattern.update(b, v)
    end
    self
  end

  def estimate(b : Board)
    value = 0.0
    @patterns.each do |pattern|
      value += pattern.estimate(b)
    end
    value
  end
end