require "./board"

abstract class Agent
  property prop

  def initialize(args : String = "")
    @prop = Hash(String, String).new
    args.sub(/ +/, ' ').split(' ').map(&.split('=')).map { |e| @prop[e[0]] = e[1] if !e[0].empty? && !e[1].empty? }
  end

  def open_episode(flag : String = "")
  end

  def close_episode(flag : String = "")
  end

  def name
    @prop["name"]? ? @prop["name"] : "unknown"
  end

  abstract def take_action(b : Board)

  def check_for_win(b : Board)
    false
  end
end

class RandomEnvironment < Agent
  property engine

  def initialize(args : String = "")
    super("name=rndenv " + args)
    @engine = Random.new
    if @prop["seed"]?
      @engine = Random.new(@prop["seed"].to_i)
    end
    @pos = StaticArray(Int32, 16).new { |i| i }
  end

  def take_action(b : Board)
    @pos.shuffle!(@engine).map do |e|
      next if b[e] != 0
      pop_tile = @engine.rand < POP_TILE_WITH_ONE_RATE ? 1 : 2
      return Action.place(pop_tile, e)
    end
    Action.new
  end
end

class Player < Agent
  property engine
  WEIGHT = StaticArray(Float64, 16).new { |i| i * 0.175 }

  def initialize(args : String)
    super("name=player " + args)
    @engine = Random.new
    if @prop["seed"]?
      @engine = Random.new(@prop["seed"].to_i)
    end    
  end

  def take_action(b : Board)
    max_op, max_v = -1, -1
    0.upto(3) do |op|
      if b.can_move?(op)
        tmp = Board.new b
        score = tmp.move!(op)
        board_v = 0
        tmp.board.each_with_index do |value, idx|
          board_v += WEIGHT[idx] * TILE_MAPPING[value]
        end
        if score + board_v > max_v
          max_v = score + board_v
          max_op = op
        end
      end
    end
    if max_op != -1
      Action.move(max_op)
    else
      Action.new
    end
  end
end