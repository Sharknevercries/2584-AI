require "./board"

class Agent
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

  def take_action(b : Board)
    Action.new
  end

  def check_for_win(b : Board)
    false
  end
end

class RandomEnvironment < Agent
  property engine

  def initialize(args : String = "")
    super("name=rndenv " + args)
    engine = Random.new
    if @prop["seed"]?
      engine = Random.new(@prop["seed"].to_i)
    end
  end

  def take_action(b : Board)
    pos = Array.new(16) { |e| e }
    pos.shuffle.map do |e|
      next if b[e] != 0
      pop_tile = engine.rand < POP_TILE_WITH_ONE_RATE ? 1 : 2
      b[e] = pop_tile
      return Action.place(pop_tile, e)
    end
    Action.new
  end
end

class Player < Agent
  property engine

  def initialize(args : String)
    puts args
    super("name=player " + args)
    engine = Random.new
    if @prop["seed"]?
      engine = Random.new(@prop["seed"].to_i)
    end    
  end

  def take_action(b : Board)
    opcode = [0, 1, 2, 3]
    opcode.shuffle.map do |op|
      after_b = Board.new b
      Action.move(op) if after_b.move(op) != -1
    end
    Action.new
  end
end