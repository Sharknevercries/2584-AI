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
    
    f_arr = [[0, 1, 2, 3, 4], [0, 1, 4, 5, 6], [1, 2, 3, 5, 6], [5, 6, 7, 9, 10]]
    f = StaticArray(StaticArray(Int32, 5), 4).new { |i|
      temp = StaticArray(Int32, 5).new 0
      f_arr[i].each_with_index do |v, idx|
        temp[idx] = v
      end
      temp
    }

    @tuple_network = TupleNetwork.new [
      Feature.new(f[0], "axe"),
      Feature.new(f[1], "thumb1"),
      Feature.new(f[2], "thumb2"),
      Feature.new(f[3], "thumb3"),
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
    @tuple_network.update(@episode[n].after, @alpha * (-@tuple_network.estimate(@episode[n].after)))

    @episode.each_cons(2, true) do |cons|
      td_error = cons[1].reward + @tuple_network.estimate(cons[1].after) - @tuple_network.estimate(cons[0].after)
      @tuple_network.update(cons[0].after, @alpha * td_error)
    end
  end

  def take_action(b : Board)
    best_op = 0
    best_value = -1e9
    after = StaticArray(State, 4).new { |op|
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
