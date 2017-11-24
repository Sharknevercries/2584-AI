struct BitBoard
  #
  # Use 5-bit to represent a grid in 2584, so it cost 80-bit to represent a board
  # @board[0] represents the grid 0~7
  # @board[1] represents the grid 8~15
  #
  property board : StaticArray(UInt64, 2)
  class_property mask1 : StaticArray(UInt64, 9) = StaticArray(UInt64, 9).new { |index|
    v = 0_u64
    b = 0b11111_u64
    index.times do |i|
      v = (v << 5) | b
    end
    v
  }
  class_property mask2 : StaticArray(UInt64, 9) = StaticArray(UInt64, 9).new { |index|
    v = 0_u64
    b = 0b1111100000000000000000000000000000000000_u64
    index.times do |i|
      v = (v >> 5) | b
    end
    v
  }

  def initialize(@board : StaticArray(UInt64, 2) = StaticArray(UInt64, 2).new 0_u64)
  end

  def initialize(b : BitBoard)
    @board = b.board.clone
  end

  # index: 0~15
  def [](index : Int) : Int
    (@board[(index & 0b1000) >> 3] >> multiply_by_5(index & 0b0111)) & 0b11111
  end

  # row, col: 0~3
  def [](row : Int, col : Int) : Int
    self[(row << 2) + col]
  end

  # index: 0~15
  # value: 0~31
  def []=(index : Int, value : Int)
    @board[(index & 0b1000) >> 3] &= ~(0b11111_u64 << multiply_by_5(index & 0b0111))
    @board[(index & 0b1000) >> 3] |= value.to_u64 << multiply_by_5(index & 0b0111)
  end

  # row, col: 0~3
  # value: 0~31
  def []=(row : Int, col : Int, value : Int)
    self[(row << 2) + col] = value
  end

  def ==(b : BitBoard)
    @board == b.board
  end

  # count : 0~15
  # TODO: improve
  def >>(count : Int)
    other = BitBoard.new self

    if count == 0
      
    elsif count < 8
      other.board[0] = other.board[0] >> multiply_by_5(count)
      temp = other.board[1] & @@mask1[count]
      other.board[0] = other.board[0] | (temp << (40 - multiply_by_5(count)))
      other.board[1] = other.board[1] >> multiply_by_5(count)
    else
      other.board[0] = other.board[1] >> multiply_by_5(count & 0b0111)
      other.board[1] = 0_u64
    end
    
    other
  end

  # count : 0~15
  # TODO: improve
  def <<(count : Int)
    other = BitBoard.new self

    if count == 0

    elsif count < 8
      other.board[1] = (other.board[1] << multiply_by_5(count & 0b0111)) & @@mask2[8]
      temp = (other.board[0] & @@mask2[count]) >> (40 - multiply_by_5(count & 0b0111))
      other.board[0] = (other.board[0] << multiply_by_5(count & 0b0111)) & @@mask2[8]
      other.board[1] = other.board[1] | temp
    else
      other.board[1] = other.board[0]
      other.board[1] = (other.board[1] << multiply_by_5(count & 0b0111)) & @@mask2[8]
      other.board[0] = 0_u64
    end

    other
  end

  def &(b : BitBoard)
    other = BitBoard.new self

    other.board[0] = @board[0] & b.board[0]
    other.board[1] = @board[1] & b.board[1]

    other
  end

  def |(b : BitBoard)
    other = BitBoard.new self
    
    other.board[0] = @board[0] | b.board[0]
    other.board[1] = @board[1] | b.board[1]
    
    other
  end

  def ^(b : BitBoard)
    other = BitBoard.new self
    
    other.board[0] = @board[0] ^ b.board[0]
    other.board[1] = @board[1] ^ b.board[1]
    
    other
  end

  def to_s(io)
    16.times do |i|
      io << self[i] << "\t"
      io << "\n" if i % 4 == 3
    end
    io << "\n"
  end
end
