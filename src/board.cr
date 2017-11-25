require "./environment"

class Board
  property board : StaticArray(Int32, 16)
  
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

  def initialize(@board : StaticArray(Int32, 16) = StaticArray(Int32, 16).new 0)
  end

  def initialize(b : Board)
    @board = b.board.clone
  end

  def ==(b : Board)
    board == b.board
  end

  def ==(b : StaticArray(Int32, 16))
    board == b
  end

  def [](tile_number)
    @board[tile_number]
  end

  def [](row, col)
    self[(row << 2) + col]
  end

  def []=(tile_number, value)
    @board[tile_number] = value
  end

  def []=(row, col, value)
    self[(row << 2) + col] = value
  end

  def transpose!
    1.upto(3) do |row|
      0.upto(row - 1) do |col|
        self[row, col], self[col, row] = self[col, row], self[row, col]
      end
    end
  end

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

  def move!(opcode)
    case opcode
    when 0
      move_up!
    when 1
      move_right!
    when 2
      move_down!
    when 3
      move_left!
    else
      -1
    end
  end

  def move_left!
    score = 0
    temp = Board.new self
    0.upto(3) do |r|
      idx = 0
      3.downto(0) do |c|
        idx = (idx << 5) | self[r, c]
      end
      cache = @@move_cache[idx]
      score += cache[1]
      tran_idx = cache[0]
      0.upto(3) do |c|
        self[r, c] = tran_idx & 0x1F
        tran_idx >>= 5
      end
    end
    self == temp ? -1 : score
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
    0.upto(15) do |tile_number|
      io << self[tile_number]
      io << "\t"
      io << "\n" if tile_number % 4 == 3
    end
  end
end
