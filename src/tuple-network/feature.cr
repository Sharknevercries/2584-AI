class Feature
  property name : String

  def initialize(@pattern : Array(Int32), @name = "No Name")
    @lut = Array(Float64).new(1 << (4 * @pattern.size), 0.0)
    
    b = Board.new (StaticArray(Int32, 16).new { |k| k })
    @iso_idxs = StaticArray(Array(Int32), 8).new { |i|
      iso = Array(Int32).new @pattern.size
      b.reflect_horizonal! if i == 4
      b.rotate_right!
      @pattern.each do |e|
        iso << b[e]
      end
      iso
    }
  end

  def [](index)
    lut[index]
  end

  def []=(index, value)
    lut[index] = value
  end

  def update(b : Board, value : Number)
    v = value / 8.0
    @iso_idxs.each do |iso_idx|
      @lut[at(b, iso_idx)] += v
    end
    self
  end

  def estimate(b : Board)
    value = 0.0
    @iso_idxs.each do |iso_idx|
      value += @lut[at(b, iso_idx)]
    end
    value
  end
  
  private def at(b : Board, idxs : Array(Int32))
    lut_idx = 0
    idxs.each do |idx|
      lut_idx = (lut_idx << 4) | (b[idx] / 2)
    end
    lut_idx
  end
end