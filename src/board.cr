require "./environment"

class Board
  property board : StaticArray(Int32, 16)

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
    self.[(row << 2) + col]
  end

  def []=(tile_number, value)
    @board[tile_number] = value
  end

  def []=(row, col, value)
    self.[(row << 2) + col] = value
  end

  def transpose!
    0.upto(3) do |row|
      0.upto(row) do |col|
        self.[row, col], self.[col, row] = self.[col, row], self.[row, col]
      end
    end
  end

  def reflect_horizonal!
    0.upto(3) do |row|
      self.[row, 0], self.[row, 3] = self.[row, 3], self.[row, 0]
      self.[row, 1], self.[row, 2] = self.[row, 2], self.[row, 1]
    end
  end

  def reflect_vertical!
    0.upto(3) do |col|
      self.[0, col], self.[3, col] = self.[3, col], self.[0, col]
      self.[1, col], self.[2, col] = self.[2, col], self.[1, col]
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
    when 3
      move_left!
    when 1
      move_right!
    when 0
      move_up!
    when 2
      move_down!
    else
      -1
    end
  end

  def to_s(io)
    0.upto(15) do |tile_number|
      print self.[tile_number]
      print "\t"
      if tile_number % 4 == 3
        puts ""
      end 
    end
  end

  def move_left!
    tmp = Board.new self
    score = 0
    0.upto(3) do |r|
      top, hold = 0, 0
      0.upto(3) do |c|
        tile = self.[r, c]
        next if tile == 0
        self.[r, c] = 0
        if hold != 0
          if (tile - hold).abs == 1 || (tile == 1 && hold == 1)
            new_tile = max(tile, hold) + 1
            self.[r, top] = new_tile
            top += 1
            score += TILE_MAPPING[new_tile]
            hold = 0
          else
            self.[r, top] = hold
            top += 1
            hold = tile
          end
        else
          hold = tile
        end
      end
      self.[r, top] = hold if hold != 0
    end
    tmp != self ? score : -1
  end

  def move_right!
    reflect_horizonal!
    score = move_left!
    reflect_horizonal!
    score
  end

  def move_up!
    rotate_right!
    score = move_right!
    rotate_left!
    score
  end

  def move_down!
    rotate_right!
    score = move_left!
    rotate_left!
    score
  end
end