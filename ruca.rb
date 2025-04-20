dictionary = {}

File.open("data/mappers.txt", "r") do |text|
  text.readlines.each do |line|
    words = line.split
    key, value = words
    dictionary[key] = value
  end
end

processed_content = ""
File.open("files/source.txt", "r") do |text|
  text.readlines.each do |line|
    words = line.split(/(\W+)/)
    transformed_words = words.map do |word|

      if word.match?(/\w+/)
        lowercase_word = word.downcase
        
        if dictionary.has_key?(lowercase_word)
          replacement = dictionary[lowercase_word]
          
          if word == word.downcase
            "<#{replacement}>"
          elsif word == word.capitalize
            "^#{replacement}>"
          elsif word == word.upcase
            "^#{replacement}^"
          else
            replacement
          end
        else
          word
        end
      else
        word
      end
    end

    processed_content += transformed_words.join
  end
end

File.open("files/output.ruca", "w") do |file|
  file.write(processed_content)
end
