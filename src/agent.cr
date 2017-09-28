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
  end

  def take_action(b : Board)
    pos = Array.new(16) { |e| e }
    pos.shuffle(@engine).map do |e|
      next if b[e] != 0
      pop_tile = @engine.rand < POP_TILE_WITH_ONE_RATE ? 1 : 2
      return Action.place(pop_tile, e)
    end
    Action.new
  end
end

class Player < Agent
  property engine

  def initialize(args : String)
    super("name=player " + args)
    @engine = Random.new
    if @prop["seed"]?
      @engine = Random.new(@prop["seed"].to_i)
    end    
  end

  def take_action(b : Board)
    opcode = [0, 1, 2, 3]
    opcode.shuffle(@engine).map do |op|
      after_b = Board.new b
      if after_b.move!(op) != -1
        return Action.move(op)
      end
    end
    Action.new
  end
end