require_relative "helpers/compress.rb"
require_relative "helpers/extract.rb"
require_relative "helpers/training.rb"

require 'optparse'

options = {}

option_parser = OptionParser.new do |argument|
  argument.banner = "Usage: ruby ruca.rb [options]"

  argument.on("-c", "--compress", "Compress a file") do
    options[:compress] = true
  end

  argument.on("-x", "--extract", "Extract a file") do
    options[:extract] = true
  end

  argument.on("-t", "--train", "Train the algorithm") do
    options[:train] = true
  end

  argument.on("-h", "--help", "Get help") do
    puts option
    exit
  end
end

option_parser.parse!

compress if options[:compress]
extract  if options[:extract]
training if options[:train]
