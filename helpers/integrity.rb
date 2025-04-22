require 'digest'

def integrity(source, output)
  hash1 = Digest::MD5.file(source).hexdigest
  hash2 = Digest::MD5.file(output).hexdigest

  puts "source: #{hash1}"
  puts "putput: #{hash2}"
end
