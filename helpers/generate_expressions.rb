def generate_expressions
  visible_chars = []
  visible_chars.concat(('A'..'Z').to_a)
  visible_chars.concat(('a'..'z').to_a)
  (33..126).each do |ascii|
    char = ascii.chr
    next if char == '^' || char == "<" || char == ">"
    visible_chars << char
  end
  visible_chars.uniq!

  def generate_combinations(charset)
    Enumerator.new do |yielder|
      length = 1
      loop do
        charset.repeated_permutation(length).each do |combo|
          yielder << combo.join
        end
        length += 1
      end
    end
  end

  words = File.readlines("data/words.txt", chomp: true)

  combinations = generate_combinations(visible_chars)

  File.open("data/mappers.txt", 'w') do |file|
    words.each do |word|
      combo = combinations.next
      file.puts "#{word} #{combo}"
    end
  end
end
