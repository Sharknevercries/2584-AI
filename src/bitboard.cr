require "./environment"

struct BitBoard
  #
  # Use 5-bit to represent a grid in 2584, so it cost 80-bit to represent a board
  # @board[0] represents the grid 0~3
  # @board[1] represents the grid 4~7
  # @board[2] represents the grid 8~11
  # @board[3] represents the grid 12~15
  #
  property board : StaticArray(Int32, 4)
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
  # (2^5)^4 = 1048576
  # a row move_left cache
  # (after_move, reward)
  class_property move_cache : Array(StaticArray(Int32, 2)) = Array.new(1048576) { |index|
    ret = StaticArray(Int32, 2).new 0
    b = StaticArray(Int32, 4).new 0

    idx = index
    4.times do |i|
      b[i] = idx & 0x1F
      idx >>= 5
    end

    score, top, hold = 0, 0, 0
    0.upto(3) do |c|
      tile = b[c]
      next if tile == 0
      b[c] = 0
      if hold != 0
        if (tile - hold).abs == 1 || (tile == 1 && hold == 1)
          new_tile = max(tile, hold) + 1
          b[top] = new_tile
          score += TILE_MAPPING[new_tile]
          hold = 0
        else
          b[top] = hold
          hold = tile
        end
        top += 1
      else
        hold = tile
      end
    end
    b[top] = hold unless hold == 0

    idx = 0
    3.downto(0) do |i|
      idx = (idx << 5) | b[i]
    end

    ret[0] = idx
    ret[1] = score
    ret
  }

  def initialize(@board : StaticArray(Int32, 4) = StaticArray(Int32, 4).new 0)
  end

  def initialize(b : BitBoard)
    @board = b.board.clone
  end

  # index: 0~15
  def [](index : Int) : Int32
    (@board[(index & 0b1100) >> 2] >> multiply_by_5(index & 0b11)) & 0b11111
  end

  # row, col: 0~3
  def [](row : Int, col : Int) : Int32
    self[(row << 2) + col]
  end

  # index: 0~15
  # value: 0~31
  def []=(index : Int, value : Int)
    row = (index & 0b1100) >> 2
    col = (index & 0b0011)
    @board[row] = (@board[row] & ~(0x1F << multiply_by_5(col))) | ((value & 0x1F) << multiply_by_5(col))
  end

  # row, col: 0~3
  # value: 0~31
  def []=(row : Int, col : Int, value : Int)
    self[(row << 2) + col] = value
  end

  def ==(b : BitBoard)
    @board == b.board
  end

  # tranpose followed by \
  def transpose!
    1.upto(3) do |row|
      0.upto(row - 1) do |col|
        self[row, col], self[col, row] = self[col, row], self[row, col]
      end
    end
  end

  # tranpose followed by /
  def transpose2!
    0.upto(2) do |row|
      0.upto(2 - row) do |col|
        self[row, col], self[3 - col, 3 - row] = self[3 - col, 3 - row], self[row, col]
      end
    end
  end

  def reflect_horizonal!
    0.upto(3) do |row|
      self[row, 0], self[row, 3] = self[row, 3], self[row, 0]
      self[row, 1], self[row, 2] = self[row, 2], self[row, 1]
    end
  end

  def reflect_vertical!
    0.upto(3) do |col|
      self[0, col], self[3, col] = self[3, col], self[0, col]
      self[1, col], self[2, col] = self[2, col], self[1, col]
    end
  end

  def rotate_right!
    transpose!
    reflect_horizonal!
  end

  def rotate_left!
    transpose!
    reflect_vertical!
  end

  def get_row(row : Int)
    @board[row]
  end

  def set_row!(row : Int, value : Int32)
    @board[row] = value
  end

  def move_left!
    score = 0
    b = BitBoard.new self
    4.times do |row|
      m = @@move_cache[get_row(row)]
      score += m[1] # reward
      set_row!(row, m[0])
    end
    b == self ? -1 : score
  end

  def move_right!
    reflect_horizonal! 
    score = move_left! 
    reflect_horizonal! 
    score 
  end

  def move_up!
    transpose! 
    score = move_left! 
    transpose! 
    score 
  end

  def move_down!
    transpose2! 
    score = move_left! 
    transpose2! 
    score 
  end

  def to_s(io)
    16.times do |i|
      io << self[i] << "\t"
      io << "\n" if i % 4 == 3
    end
    io << "\n"
  end
end
