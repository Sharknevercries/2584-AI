require "./environment"

class Board
  TILE_MAPPING = {
    0 => 0,
    1 => 1,
    2 => 2,
    3 => 3,
    4 => 5,
    5 => 8,
    6 => 13,
    7 => 21,
    8 => 34,
    9 => 55,
    10 => 89,
    11 => 144,
    12 => 233,
    13 => 377,
    14 => 610,
    15 => 987,
    16 => 1597,
    17 => 2584,
    18 => 4181,
    19 => 6765,
    20 => 10946,
    21 => 17711,
    22 => 28657,
    23 => 46368,
    24 => 75025,
    25 => 121393,
    26 => 196418,
    27 => 317811,
    28 => 514229,
    29 => 832040,
    30 => 1346269
  }

  property board : Array(Int32)

  def initialize(@board : Array(Int32) = [0] * 16)
  end

  def initialize(b : Board)
    @board = b.board.clone
  end

  def ==(b : Board)
    board == b.board
  end

  def ==(b : Array(Int32))
    board == b
  end

  def [](tile_number)
    @board[tile_number]
  end

  def [](row, col)
    self.[row * 4 + col]
  end

  def []=(tile_number, value)
    @board[tile_number] = value
  end

  def []=(row, col, value)
    self.[row * 4 + col] = value
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
    temp_board = Board.new self
    0.upto(3) do |row|
      0.upto(3) do |col|
        self.[row, col] = temp_board[3 - col, row]
      end
    end
  end

  def rotate_left!
    temp_board = Board.new self
    0.upto(3) do |row|
      0.upto(3) do |col|
        self.[row, col] = temp_board[col, 3 - row]
      end
    end
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
    merged = [false] * 16
    score = 0
    0.upto(15) do |tile_number|
      next if self.[tile_number] == 0
      left_most_tile_number = (tile_number / 4) * 4
      target_tile_number = tile_number
      t = target_tile_number - left_most_tile_number
      value = self.[tile_number]
      self.[tile_number] = 0

      t.times do |e|
        target_tile_number -= 1
        next if self.[target_tile_number] == 0
        found = false
        if ((value - self.[target_tile_number]).abs == 1 || (value == 1 && self.[target_tile_number] == 1)) && !merged[target_tile_number]
          value = [value, self.[target_tile_number]].max + 1
          score += TILE_MAPPING[value]
          merged[target_tile_number] = true
          found = true
        else
          target_tile_number += 1
          break
        end
        break if found
      end
      self.[target_tile_number] = value
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