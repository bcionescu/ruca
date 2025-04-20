$new_text = ""

File.open("data/sorted.txt", "r") do |text|
  
  text.readlines.each do |line|
    line = line.chomp.gsub(/ .*/, "")
    $new_text += "#{line}\n"
  end
end

File.open("data/words.txt", "w") do |file|
  file.write($new_text)
end
