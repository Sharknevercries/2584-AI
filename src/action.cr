class Action
  property opcode

  def initialize(act : Action)
    @opcode = act.opcode
  end

  def initialize(op : Int32 = -1)
    @opcode = op
  end

  def apply!(b : Board)
    if (0b11 & @opcode) == @opcode # human
      b.move!(opcode) 
    elsif (b[@opcode & 0x0f]) == 0
      b[@opcode & 0x0f] = @opcode >> 4
      0
    else
      -1
    end
  end

  def name
    if ((0b11 & @opcode) == @opcode)
      opname = ["up", "right", "down", "left"]
      return "slide #{opname[opcode]}"
    else
      return "place #{@opcode >> 4}-index at position #{@opcode & 0x0f}" 
    end
  end

  def self.move(oper : Int32)
    Action.new oper
  end

  def self.place(tile : Int32, pos : Int32)
    Action.new ((tile << 4) | pos)
  end
end