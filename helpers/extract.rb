require_relative "integrity.rb"

root = File.expand_path("../../", __FILE__)

ruca_file = "#{root}/files/output.ruca"
mappers =   "#{root}/data/mappers.txt"
source =    "#{root}/files/source.txt"
output =    "#{root}/files/extracted.txt"


dictionary = {}

File.open(mappers, "r") do |mappers|
  mappers.readlines.each do |line|
    words = line.split
    key, value = words[0], words[1]
    dictionary[key] = value
  end
end

File.open(ruca_file, "r") do |text|
  content = text.read

  dictionary.each do |key, value|
    content.gsub!("<#{value}>", key)
    content.gsub!("^#{value}>", key.capitalize)
    content.gsub!("^#{value}^", key.upcase)
  end

  File.open(output, "w") do |file|
    file.write(content)
  end
end

integrity(source, output)
