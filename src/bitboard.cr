require "./environment"

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
  # (2^5)^4 = 1048576
  # a row move_left cache
  # (after_move, reward)
  class_property move_cache : Array(StaticArray(Int32, 2)) = Array.new(1048576) { |index|
    ret = StaticArray(Int32, 2).new 0
    b = StaticArray(Int32, 4).new 0

    larger_than_25 = false
    temp = index
    4.times do |i|
      break if temp == 0
      b[i] = temp % 32
      larger_than_25 = true if b[i] > 25
      temp >>= 5
    end

    if !larger_than_25
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

      temp = 0
      3.downto(0) do |i|
        temp = (temp << 5) + b[i]
      end

      ret[0] = temp
    end
    ret[1] = score
    ret
  }

  def initialize(@board : StaticArray(UInt64, 2) = StaticArray(UInt64, 2).new 0_u64)
  end

  def initialize(b : BitBoard)
    @board = b.board.clone
  end

  # index: 0~15
  def [](index : Int) : Int32
    ((@board[(index & 0b1000) >> 3] >> multiply_by_5(index & 0b0111)) & 0b11111).to_i
  end

  # row, col: 0~3
  def [](row : Int, col : Int) : Int32
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
  def >>(count : Int) : BitBoard
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
  def <<(count : Int) : BitBoard
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

  def &(b : BitBoard) : BitBoard
    other = BitBoard.new self

    other.board[0] = @board[0] & b.board[0]
    other.board[1] = @board[1] & b.board[1]

    other
  end

  def |(b : BitBoard) : BitBoard
    other = BitBoard.new self
    
    other.board[0] = @board[0] | b.board[0]
    other.board[1] = @board[1] | b.board[1]
    
    other
  end

  def ^(b : BitBoard) : BitBoard
    other = BitBoard.new self
    
    other.board[0] = @board[0] ^ b.board[0]
    other.board[1] = @board[1] ^ b.board[1]
    
    other
  end

  # tranpose followed by \
  def transpose! : BitBoard
    x = @board[0]
    y = @board[1]
    
    t = (x ^ (x >> multiply_by_5(3))) & 0xF83E0_u64
    @board[0] = x ^ t ^ ((t << multiply_by_5(3)) & @@mask1[8])
    t = (y ^ (y >> multiply_by_5(3))) & 0xF83E0_u64
    @board[1] = y ^ t ^ ((t << multiply_by_5(3)) & @@mask1[8])
    
    x = (@board[0] >> multiply_by_5(2)) & 0x3FF003FF_u64
    y = @board[1] & 0x3FF003FF_u64

    @board[0] = (@board[0] & 0x3FF003FF_u64) | (y << multiply_by_5(2))
    @board[1] = (@board[1] & (~(0x3FF003FF_u64))) | x

    self
  end

  # tranpose followed by /
  def transpose2! : BitBoard
    x = @board[0]
    y = @board[1]
        
    t = (x ^ (x >> multiply_by_5(5))) & 0x07C1F_u64
    @board[0] = x ^ t ^ ((t << multiply_by_5(5)) & @@mask1[8])
    t = (y ^ (y >> multiply_by_5(5))) & 0x07C1F_u64
    @board[1] = y ^ t ^ ((t << multiply_by_5(5)) & @@mask1[8])
        
    y = (@board[1] >> multiply_by_5(2)) & 0x3FF003FF_u64
    x = @board[0] & 0x3FF003FF_u64
    
    @board[1] = (@board[1] & 0x3FF003FF_u64) | (x << multiply_by_5(2))
    @board[0] = (@board[0] & (~(0x3FF003FF_u64))) | y

    self
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
    (@board[(row & 0b10) >> 1] >> multiply_by_5((row & 1) << 2)) & 0xFFFFF_u64
  end

  def set_row!(row : Int, value : Int32)
    @board[(row & 0b10) >> 1] &= (~(0xFFFFF_u64 << multiply_by_5((row & 1) << 2))) & 0xFFFFFFFFFF_u64
    @board[(row & 0b10) >> 1] |= (value.to_u64 << (multiply_by_5((row & 1) << 2)))
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
