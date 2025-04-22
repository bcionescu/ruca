def training
  $new_words = ""

  File.open("data/training.txt", "r") do |text|
    text = text.read.downcase()
    $training_words = text.scan(/\b[\w']+\b/)
  end

  word_counts = []
  File.open("data/words.txt", "r") do |text|
    text.readlines.each do |line|
      line = line.chomp
      count = $training_words.count(line)
      puts "#{line} #{count}"
      word_counts << { word: line, count: count }
    end
  end

  word_counts.sort_by! { |entry| -entry[:count] }

  $new_words = word_counts.map { |entry| "#{entry[:word]} #{entry[:count]}" }.join("\n") + "\n"

  File.open("data/sorted.txt", "w") do |file|
    file.write($new_words)
  end
end

