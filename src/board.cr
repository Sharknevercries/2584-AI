require "./environment"
require "./bitboard"

class Board
  property board : BitBoard

  def initialize(@board : BitBoard = BitBoard.new)
  end

  def initialize(b : StaticArray(UInt64, 2)) 
    @board = BitBoard.new b
  end

  def initialize(b : Board)
    @board = b.board
  end

  def ==(b : Board)
    board == b.board
  end

  def ==(b : StaticArray(UInt64, 2))
    board == b
  end

  def [](tile_number)
    @board[tile_number]
  end

  def [](row, col)
    @board[row, col]
  end

  def []=(tile_number, value)
    @board[tile_number] = value
  end

  def []=(row, col, value)
    @board[row, col] = value
  end

  def transpose!
    @board.transpose!
  end

  def transpose2!
    @board.transpose2!
  end

  def reflect_horizonal!
    @board.reflect_horizonal!
  end

  def reflect_vertical!
    @board.reflect_vertical!
  end

  def rotate_right!
    @board.rotate_right!
  end

  def rotate_left!
    @board.rotate_left!
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
    @board.move_left!
  end

  def move_right!
    @board.move_right!
  end

  def move_up!
    @board.move_up!
  end

  def move_down!
    @board.move_down!
  end

  def to_s(io)
    io << @board
  end
end
