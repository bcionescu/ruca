def sort_words_by_length
  file_path = 'data/words.txt'
  lines = File.readlines(file_path)

  sorted_lines = lines.sort_by(&:length)

  File.open('data/words.txt', 'w') do |file|
    sorted_lines.each { |line| file.puts(line) }
  end
end
