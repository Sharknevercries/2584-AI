require "./board"
require "./tuple-network/*"

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

  def initialize(args : String)
    super("name=player " + args)
    @engine = @prop["seed"]? ? Random.new(@prop["seed"].to_i) : Random.new
    @alpha = @prop["alpha"]? ? @prop["alpha"].to_f : 0.0025
    @save_path = @prop["save"]? ? @prop["save"] : ""
    @load_path = @prop["load"]? ? @prop["load"] : ""
    @tuple_network = TupleNetwork.new [
      Feature.new([0, 1, 2, 3], "row1"),
      Feature.new([4, 5, 6, 7], "row2")
    ]
    @episode = Array(State).new 20000
    load_tuple_network
  end

  def save_tuple_network
    @tuple_network.save(@save_path) if !@save_path.empty?
  end

  def load_tuple_network
    @tuple_network.load(@load_path) if !@load_path.empty?
  end

  def save_state(state : State)
    @episode << state
  end

  def routine_after_all_play
    save_tuple_network
  end
  
  def open_episode(flag : String = "")
    @episode.clear
  end

  def close_episode(flag : String = "")
    n = @episode.size - 1
    while n > 0
      prev, cur = @episode[n - 1], @episode[n]
      td_error = 0.0
      if n == @episode.size - 1
        td_error = 0 - @tuple_network.estimate(prev.after)
      else
        td_error = cur.reward + @tuple_network.estimate(cur.after) - @tuple_network.estimate(prev.after)
      end
      @tuple_network.update(prev.after, @alpha * td_error)
      n -= 1
    end
  end

  def take_action(b : Board)
    best_op = 0
    best_value = -1e9
    after = Array(State).new 4 { |op|
      temp = Board.new b
      reward = temp.move!(op)
      if reward != -1
        estimate = @tuple_network.estimate(temp)
        best_op, best_value = op, reward + estimate if reward + estimate > best_value
      else
        reward = 0
      end
      State.new(temp, reward)
    }
    save_state(after[best_op])
    best_value == -1e9 ? Action.new : Action.move best_op
  end

  private struct State
    property after : Board
    property reward : Int32

    def initialize(@after, @reward)
    end
  end
end