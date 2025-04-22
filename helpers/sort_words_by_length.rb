def sort_words_by_length
  root = File.expand_path("../../", __FILE__)
  
  words_path = "#{root}/data/words.txt"
  lines = File.readlines(words_path)

  sorted_lines = lines.sort_by(&:length)

  File.open(words_path, "w") do |file|
    sorted_lines.each { |line| file.puts(line) }
  end
end
