def training
  root = File.expand_path("../../", __FILE__)

  training_path = "#{root}/data/training.txt"
  sorted_path   = "#{root}/data/sorted.txt"
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
      puts "#{line} #{count}"
      word_counts << { word: line, count: count }
    end
  end

  word_counts.sort_by! { |entry| -entry[:count] }

  $new_words = word_counts.map { |entry| "#{entry[:word]} #{entry[:count]}" }.join("\n") + "\n"

  File.open(sorted_path", "w") do |file|
    file.write($new_words)
  end
end

