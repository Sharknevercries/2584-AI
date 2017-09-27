require "./*"
require "option_parser"

total = 1000
player_args = ""
evil_args = ""
save = ""
summary = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: 2584-AI [arguments]"
  parser.on("--total=TOTAL_GAMES", "Indicate how many games to play") { |n| total = n }
  #parser.on("--block=BLOCK", "...") { |n| block = n }
  parser.on("--play=PLAYER_ARGS", "The arguments of player initialization") { |args| player_args = args }
  parser.on("--evil=EVIL_ARGS", "The arguments of evil (environment) initialization") { |args| evil_args = args }
  #parser.on("--load=LOAD", "Specifies the name to salute") { |name| load = name }
  parser.on("--save=SAVE", "Path to save statistic data") { |path| save = path }
  #parser.on("--summary", "Specifies the name to salute") { summary = true }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

player = Player.new player_args
environment = RandomEnvironment.new evil_args
