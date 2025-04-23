require_relative "sort_words_by_length.rb"
require_relative "remove_rankings.rb"
require_relative "generate_expressions.rb"

def training
  root = File.expand_path("../../", __FILE__)
  
  training_path = "#{root}/data/training.txt"
  words_path    = "#{root}/data/words.txt"
  
  $new_words = ""

  File.open(training_path, "r") do |text|
    text = text.read.downcase()
    $training_words = text.scan(/\b[\w']+\b/)
  end

  word_counts = []
  File.open(words_path, "r") do |text|
    text.readlines.each do |line|
      line = line.chomp
      count = $training_words.count(line)
      # puts "#{line} #{count}"
      word_counts << { word: line, count: count }
    end
  end

  word_counts.sort_by! { |entry| -entry[:count] }

  $new_words = word_counts.map { |entry| "#{entry[:word]} #{entry[:count]}" }.join("\n") + "\n"

  File.open(words_path, "w") do |file|
    file.write($new_words)
  end
end

puts "> Sorting the word list by length"
STDOUT.flush
# sort_words_by_length

puts "> Training the algorithm"
STDOUT.flush
# training

puts "> Removing the word rankings"
STDOUT.flush
# remove_rankings

puts "> Generating the mini-expressions"
STDOUT.flush
generate_expressions

puts "> Finished!"
