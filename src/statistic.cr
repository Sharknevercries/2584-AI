require "./agent"
require "./action"
require "./board"

class Statistic
  property data

  def initialize(@total : Int32, @block = 0)
    @block = @block != 0 ? @block : @total
    @data = [] of Record
  end

  def show
    block = [@data.size, @block].min
    sum, max, opc, duration = 0, 0 ,0, 0
    stat = [0] * TILE_MAPPING.size
    iter = @data.reverse_each

    block.times do |i|
      path = iter.next.as(Record)
      game = Board.new
      score = 0
      path.actions.each do |move|
        score += move.apply!(game)
      end
      sum += score
      max = [score, max].max
      opc += (path.actions.size - 2) / 2
      tile = 0
      0.upto(15) do |t|
        tile = [tile, game[t]].max
      end
      stat[tile] += 1
      duration += path.tock_time - path.tick_time
    end
    
    avg = sum.to_f / block
    coef = 100.0 / block
    ops = opc * 1000.0 / duration
    puts "%d\tavg = %d, max = %d, ops = %d" % [@data.size, avg.to_i, max.to_i, ops.to_i]

    t, c = 0, 0
    while c < block
      # to be fixed
      if stat[t] == 0
        c += stat[t]
        t += 1
        next
      end
      accu = stat[t..(stat.size)].sum
      puts "\t%d\t%.2f%%\t(%.2f%%)" % [TILE_MAPPING[t], accu * coef, stat[t] * coef]
      c += stat[t]
      t += 1
    end
    puts ""
  end

  def is_finished
    @data.size >= @total
  end

  def open_episode
    @data << Record.new
    @data[-1].tick
  end

  def close_episode
    @data[-1].tock
    show if @data.size % @block == 0
  end

  def save_action(move : Action)
    @data[-1].actions << move
  end

  def take_turns(player : Agent, evil : Agent)
    ([@data[-1].actions.size + 1, 2].max % 2 == 1) ? player : evil
  end

  def last_turns(player : Agent, evil : Agent)
    take_turns(evil, player)
  end

  def log(file : File)
    file.write_bytes(@data.size.to_u64, IO::ByteFormat::LittleEndian)
    @data.each do |rec|
      rec.log(file)
    end
  end

  class Record
    property actions
    getter tick_time
    getter tock_time
    
    def initialize
      @actions = [] of Action
      @tick_time = 0_i64
      @tock_time = 0_i64
    end

    def tick
      @tick_time = Time.new.epoch_ms
    end

    def tock
      @tock_time = Time.new.epoch_ms
    end

    def log(file : File)
      file.write_bytes(@actions.size.to_u64, IO::ByteFormat::LittleEndian)
      @actions.each do |action|
        file.write_bytes(action.to_i.to_u16, IO::ByteFormat::LittleEndian)
      end
      file.write_bytes(@tick_time, IO::ByteFormat::LittleEndian)
      file.write_bytes(@tock_time, IO::ByteFormat::LittleEndian)
    end
  end
end