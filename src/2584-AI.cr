require "./*"
require "option_parser"

total = 1000
block = 0
player_args = ""
evil_args = ""
save = ""
summary = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: 2584-AI [arguments]"
  parser.on("--total=TOTAL_GAMES", "Indicate how many games to play") { |n| total = n.to_i }
  parser.on("--block=BLOCK", "...") { |n| block = n.to_i }
  parser.on("--play=PLAYER_ARGS", "The arguments of player initialization") { |args| player_args = args }
  parser.on("--evil=EVIL_ARGS", "The arguments of evil (environment) initialization") { |args| evil_args = args }
  #parser.on("--load=LOAD", "Specifies the name to salute") { |name| load = name }
  parser.on("--save=SAVE", "Path to save statistic data") { |path| save = path }
  #parser.on("--summary", "Specifies the name to salute") { summary = true }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

player = Player.new player_args
evil = RandomEnvironment.new evil_args

stat = Statistic.new(total, block)

while !stat.is_finished
  stat.open_episode
  game = Board.new
  loop do
    who = stat.take_turns(player, evil)
    move = who.take_action(game)
    break if move.apply!(game) == -1
    stat.save_action(move)
  end
  winner = stat.last_turns(player, evil)
  stat.close_episode
end

if !save.empty?
  File.open(save, "w") do |f|
    stat.log(f)
    f.flush
  end
end