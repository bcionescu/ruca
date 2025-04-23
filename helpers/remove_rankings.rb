def remove_rankings
  root = File.expand_path("../../", __FILE__)

  words_path  = "#{root}/data/words.txt"
  
  $new_text = ""

  File.open(words_path, "r") do |text|
    text.readlines.each do |line|
      line = line.chomp.gsub(/ .*/, "")
      $new_text += "#{line}\n"
    end
  end

  File.open(words_path, "w") do |file|
    file.write($new_text)
  end
end
