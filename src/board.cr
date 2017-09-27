require "./environment"

class Board
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

  def add_random_tile!
    
  end

  def transpose!
    0.upto(3) do |row|
      0.upto(row) do |col|
        self.[row, col], self.[col, row] = self.[col, row], self.[row, col]
      end
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

  def move!(direction)
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
end