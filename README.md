# ruca

![ruca.rb](/data/ruca.png)

Later edit: This project was made as part of an application to 37signals, for which I was invited to participate in a take-home coding exercise. Building the project was not a requirement, but something I wanted to do regardless. As the original intro was directed at their hiring team, I've edited this first paragraph slightly, so that it makes more sense to read outside of that context.

This is `ruca`, or **Ru**by **C**ompression **A**lgorithm. Data compression is fascinating. Using logic, one can take a certain amount of information, shrink it, and then decompress it again, losing (ideally) none of the original information. The premise of the project is this: if data compression did not exist, how would *I* build it?

## Aim

This algorithm will focus exclusively on text. We will disregard any other types of files for now, as that is currently out of scope. We can always iterate on this later. Let us begin by breaking this large problem into many smaller ones.

## How?

It seems to me that the way to compress data would be to replace larger words with smaller ones—let's call that a *mini-expression*. How do we differentiate between the *mini-expression* and random bits of text that may resemble it when decompressing? We make it unmistakable by wrapping symbols around it, like how HTML does—we'll call this a *wrapper*. Together, we could refer to the mini-expression + wrapper as a *mapper*.

## Words

Which mini-expression will be assigned to what word? Naturally, it makes more sense to assign a smaller shorthand to a larger word, to get the best compression ratio possible. However, that large word may not be used very often, thus wasting the potential of the smaller mini-expressions. As a result, the smallest mini-expression should be assigned to the most popular word, assuming the mappers are smaller than the words they are replacing.

Now, how do we determine what the most popular words are?

## Popularity

My first thought was to determine the most popular words within the text and replace those with the shorthand, or mini-expressions. This would eliminate the need to create a large word list. However, this would also require us to include a key-value pair list inside the file, associating each word to its shorthand for the purpose of decompression later.

This would *add* data, potentially making the file larger if it was small enough to begin with, although this inefficiency would be less obvious for larger files.

In conclusion, if we want to retain efficiency with smaller files as well, we should instead source multiple lists of words, combine them, remove any duplicates, and then figure out a way to sort them by popularity. The list is not included in this repo, as it contains some profanity, and I am not sure if this is technically allowed on GitHub; however, many such lists can be found online.

## Sorting

To determine how "popular" a word is, the algorithm needs to be "trained". In order to do this, I used the top five most downloaded books on Project Gutenberg, plus the entire works of Shakespeare, and, of course, Bram Stoker's *Dracula*—fitting, as I am Romanian :)

The beauty of this utility is that you can train it on whatever material you want, and the compression would become more effective in that domain. For example, you could train it on medical journals, and since the shortest mini-expressions would be assigned the most common words in that field, you'd get a better compression ratio.

Before we begin sorting the list by popularity, we should first sort it by length, with the shortest words first. Most of the list will be changed when we run the programs below; however, the words with an occurrence of 0 in the training data will grow in size as the list goes on. This way, the longer words will get the longer mini-expressions.

```ruby
def sort_words_by_length
  root = File.expand_path("../../", __FILE__)
  
  words_path = "#{root}/data/words.txt"
  lines = File.readlines(words_path)

  sorted_lines = lines.sort_by(&:length)

  File.open(words_path, "w") do |file|
    sorted_lines.each { |line| file.puts(line) }
  end
end

```

Now we can begin the training. The code below iterates through my word list and calculates the number of times each word appears in the provided training material. The `.rb` file, as well as all the other snippets of code, are also available above, in the repo.

```ruby
require_relative "sort_words_by_length.rb"
require_relative "remove_rankings.rb"
require_relative "generate_expressions.rb"

def training
  root = File.expand_path("../../", __FILE__)
  
  training_path = "#{root}/data/training.txt"
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
      # puts "#{line} #{count}"
      word_counts << { word: line, count: count }
    end
  end

  word_counts.sort_by! { |entry| -entry[:count] }

  $new_words = word_counts.map { |entry| "#{entry[:word]} #{entry[:count]}" }.join("\n") + "\n"

  File.open(words_path, "w") do |file|
    file.write($new_words)
  end
end

def initiate_training
  puts "> Sorting the word list by length"
  STDOUT.flush
  sort_words_by_length

  puts "> Training the algorithm"
  STDOUT.flush
  training

  puts "> Removing the word rankings"
  STDOUT.flush
  remove_rankings

  puts "> Generating the mini-expressions"
  STDOUT.flush
  generate_expressions

  puts "> Finished!"
end
```

Once the training is finished, a number is added next to each word in the list, separated by a space. Once each word has been examined, the list is sorted in descending order by the number of occurrences. I'll now break down the code above into smaller pieces and explain how it works.

```ruby
  File.open(training_path, "r") do |text|
    text = text.read.downcase()
    $training_words = text.scan(/\b[\w']+\b/)
  end
```

The above opens the `training.txt` file, attributes its contents to a variable, and makes it all lowercase. Then, a regex is used to scan through the text, find the boundaries of the words, and then extract them.

```ruby
  word_counts = []
  File.open(words_path, "r") do |text|
    text.readlines.each do |line|
      line = line.chomp
      count = $training_words.count(line)
      # puts "#{line} #{count}"
      word_counts << { word: line, count: count }
    end
  end
```

Next up, we open the words.txt file, which is the word list I have assembled, and we count how many times each word appears in the training data. We then add the word, with its word count, to the `word_counts` array.

```ruby
word_counts.sort_by! { |entry| -entry[:count] }

  $new_words = word_counts.map { |entry| "#{entry[:word]} #{entry[:count]}" }.join("\n") + "\n"

  File.open(words_path, "w") do |file|
    file.write($new_words)
  end
end
```

The code above orders the array based on the count, and then reassembles the list, which is saved as `sorted.txt`. Here is an excerpt from the top of the file, with the most commonly used words and their occurrence number in the training data. Due to the minimum mapper character length of three, I only included words with four or more characters in the initial word list. I'll expand on the minimum mapper length in a bit.

```text
that 20887
with 13832
this 10500
have 9522
your 8461
what 7020
will 6991
thou 6495
from 5682
which 5110
shall 4773
they 4745
there 4537
when 4382
would 4074
then 3987
more 3973
their 3897
were 3882
```

The most commonly used word appears first, the second most common appears second, and so on. The code below describes how the list is then cleaned of numbers and the extra space, to allow only the words.

```ruby
def remove_rankings
  root = File.expand_path("../../", __FILE__)

  words_path = "#{root}/data/words.txt"
  
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
```

The code goes through each line, one by one, and regex is used in order for `gsub` to substitute everything `.*` after the first space with nothing.

## Shorthand

For the actual mini-expressions, we can use a combination of digits, upper- and lowercase letters, and symbols, excluding some, which we will reserve for the wrapper. This will avoid confusion when decompressing. Excluding the wrapper, the smallest shorthand can be any one digit, like the letter a, P, the number 5, or the symbol $.

Now that we've established that, which precise symbols do we use, which do we exclude, what is the minimum amount, and how do we communicate the most amount of data through them?

## Symbols

This is where I ended up iterating through multiple ideas. As I'm running out of time to submit my application, I went with a simpler implementation. However, I would like to return to this later, especially once I know more Ruby, and try the more complicated one too, which might achieve a better compression ratio.

Here is the simpler implementation, which is what I went with for V1: wrap two symbols around the shorthand, indicating capitalisation. Assuming the shorthand was, say `aP`, we could do `^aP^` to indicate upper case, `<aP>` to indicate lowercase, and `^aP>` to indicate that only the first letter of the word was capitalized.

So, if the word was *parallel*, and the mini-expression assigned to it was `aP`, the mapper would be `<aP>`. If the word was *Parallel*, the mapper would be `^aP>`. Finally, if the word was *PARALLEL*, the mapper would be `^aP^`. This would allow us to indicate capitalisation, without having to sacrifice mini-expression permutations.

The more complicated but potentially more efficient idea was this: given that we are only compressing text, there should be many instances of words combined with letters, e.g., 1up. As a result, our mappers could have a similar syntax. As a bonus, we could use the wrapper to indicate the elements surrounding the word, such as spaces or punctuation, increasing efficiency even further.

We could use digits as wrappers, to denote spaces, punctuation, etc. Using digits instead of symbols makes more sense, as we can denote a range of things, and we can use the symbols inside the shorthand instead. However, this means that we can not use digits in the shorthand itself, as it may cause confusion.

Now, 0 means nothing, 1 is space, 2 is a period, 3 is a comma, 4 is !, 5 is ?, 6 is :, 7 is ;, 8 is ', and 9 is ". 

Assuming the shorthand for the word *patterns* is "$", the mapper for " patterns " would be "1$1", " patterns." would be "1$2", and " patterns" would be "1$0". If a word is capitalized, such as "Patterns " this would become "0^$1".

In rare cases, where the text is all upper case, as in " PATTERNS " it would be "1^$^1". This means that `^` would have to be excluded from the list of possible symbols we could use for shorthand, along with digits.

```ruby
def generate_expressions
  root = File.expand_path("../../", __FILE__)

  words_path   = "#{root}/data/words.txt"
  mappers_path = "#{root}/data/mappers.txt"

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

  words = File.readlines(words_path, chomp: true)

  combinations = generate_combinations(visible_chars)

  File.open(mappers_path, 'w') do |file|
    words.each do |word|
      combo = combinations.next
      file.puts "#{word} #{combo}"
    end
  end
end
```

The code above creates a list of acceptable characters to use for the mini-expressions, excluding `^`, `<`, and `>`, as these are reserved for the wrapper. We then import all the words in our list, and we generate a mini-expression for each. Here is what some of the list looks like, based on my training data.

```txt
that A
with B
this C
have D
your E
what F
will G
...
happy Cd
less Ce
return Cf
news Cg
miss Ch
open Ci
rome Cj
sword Ck
...
xiii AB*
cozen AB+
apartments AB,
ravens AB-
ambush AB.
strangled AB/
ostentation AB0
entailed AB1
savours AB2
```
## Collisions

Given the uniqueness of the mappers, it is highly unlikely that any original text already contains a mapper, thus causing a collision. As a result, a way to address these will not be included in this version of the algorithm to limit the scope of the project. However, there is a way to mitigate this. If the original text contains something that may be misinterpreted as a mapper, we need to mark it so that it can be excluded. As a final step, when the decompression happens, the marking can be removed.

So, before compression starts, the program must scan through the text to see if it already contains any mappers. If found, it will wrap them in `<!< >!>`. For example, if `<$>` is already present, it would be turned into `<!<$>!>`. Doing so will mark it as ignorable.

When decompression happens, any instance of `<!<` and `>!>` would simply be removed.

## Compression

Now that the list is complete, we can compress text.

```ruby
def compress
      
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
            
            case word
            when word.upcase then     "^#{replacement}^"
            when word.downcase then   "<#{replacement}>"
            when word.capitalize then "^#{replacement}>"
            else replacement
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
end

```

The above loads the `mappers.txt` file into a dictionary or a hash, storing each word and its assigned mini-expression as a key-value pair. Then, the text to be compressed is loaded from `source.txt`. Everything is then split up and placed into an array. As we iterate through each element of this array, we check if it is a word or just punctuation. If it's punctuation, we just put it back. However, if it is a word, we check for capitalisation.

If it is lowercase, we replace the word with its mini-expression, and we wrap it with `<>`. If it is uppercase, we wrap its shorthand with `^^`. If it is capitalised, we wrap its value with `^>`. Finally, if it's none of the above, we simply put the word back. This can occur with something like camelCase. The final result is then written to `output.ruca`. Below you will find an example of text in its original form, and what it looks like once compressed.

```original
When we started, the crowd round the inn door, 
which had by this time swelled to a considerable 
size, all made the sign of the cross and pointed 
two fingers towards me. With some difficulty I 
got a fellow-passenger to tell me what they meant; 
he would not answer at first, but on learning that 
I was English, he explained that it was a charm or 
guard against the evil eye. This was not very 
pleasant for me, just starting for an unknown place 
to meet an unknown man; but every one seemed so 
kind-hearted, and so sorrowful, and so sympathetic 
that I could not but be touched.
```

```compressed
^N> we <Ub>, the <ok> <B[> the inn <B]>, 
<J> had by <C> <n> <74> to a <U2> 
<k[>, all <+> the <LB> of the <Ip> and <R8> 
two <QC> <Cq> me. ^B> <d> <bG> I 
got a <B8>-<8%> to <(> me <F> <L> <K)>; 
he <O> not <BU> at <s>, but on <cn> <A> 
I was ^E:>, he <t:> <A> it was a <Va> or 
<H}> <Af> the <I6> eye. ^C> was not <t> 
<O]> for me, <Bp> <nd> for an <Md> <AZ> 
to <CE> an <Md> man; but <AB> one <A~> so 
<B$>-<UQ>, and so <(6>, and so <A't> 
<A> I <q> not but be <Sh>.
```

The original text measures 574 bytes, whereas the compressed text measures only 458 bytes—an improvement of around 20%. When compressed with `.zip`, the resulting file was 488 bytes, and a `.7zip` compression achieved 527 bytes.

```shell
.rw-r--r--@ 574 admin 20 Apr 22:36 ├── source.txt
.rw-r--r--@ 458 admin 20 Apr 22:36 ├── output.ruca
.rw-r--r--@ 488 admin 20 Apr 22:39 ├── source.txt.zip
.rw-r--r--@ 527 admin 20 Apr 22:39 └── source.txt.7z
```

When compressing the entirety of Bram Stoker's *Dracula*, however, it was a different story.

```Shell
.rw-r--r--@ 875k admin 20 Apr 22:42 ├── source.txt
.rw-r--r--  733k admin 20 Apr 22:42 ├── output.ruca
.rw-r--r--@ 275k admin 20 Apr 22:42 ├── source.txt.7z
.rw-r--r--@ 319k admin 20 Apr 22:42 └── source.txt.zip
```

It is evident that the ZIP and 7-Zip` algorithms become more efficient with scale.

## Extraction

Given that each word can have three possible mappers, a simple way to extract the data would be to go through the word list and look for the three possible mappers in the text, based on the expression. If found, replace it with the original word. This approach is less efficient, as we have to go through the entire word list. However, it is far less prone to conflicts. This is the current implementation for this.

```ruby
def extract

  require_relative "integrity.rb"

  root = File.expand_path("../../", __FILE__)

  ruca_file = "#{root}/files/output.ruca"
  mappers   = "#{root}/data/mappers.txt"
  source    = "#{root}/files/source.txt"
  output    = "#{root}/files/extracted.txt"

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
end

```

At the end, the `integrity` method is called, the role of which is to generate an MD5 hash of the original file and the extracted one. This will ensure the two files are identical and that no conflicts have occurred. The method can be seen below.

```ruby
require 'digest'

def integrity(source, output)
  hash1 = Digest::MD5.file(source).hexdigest
  hash2 = Digest::MD5.file(output).hexdigest

  puts "source: #{hash1}"
  puts "output: #{hash2}"
end
```

## Utility

Finally, all the code above comes together as one utility, which can be given arguments from the terminal. Executing `ruby ruca.rb -c` will compress the file, `-x` will extract the file, `-t` will initiate a training session, and `-h` will help guide you, if needed.

```ruby
require_relative "helpers/compress.rb"
require_relative "helpers/extract.rb"
require_relative "helpers/training.rb"

require 'optparse'

options = {}

option_parser = OptionParser.new do |argument|
  argument.banner = "Usage: ruby ruca.rb [options]"

  argument.on("-c", "--compress", "Compress a file") do
    options[:compress] = true
  end

  argument.on("-x", "--extract", "Extract a file") do
    options[:extract] = true
  end

  argument.on("-t", "--train", "Train the algorithm") do
    options[:train] = true
  end

  argument.on("-h", "--help", "Get help") do
    puts option
    exit
  end
end

option_parser.parse!

compress if options[:compress]
extract if options[:extract]
initiate_training if options[:train]
```

## Future Improvements

A potential way to improve the algorithm further is to include common expressions instead of just words. Replacing an entire sentence with a 3-character mapper would be quite efficient. Additionally, I need to implement a method for the user to specify the path to a file to compress/extract, as the code only currently allows for fixed paths.

Finally, it might make sense to have a version of this algorithm that takes each word in a text and assigns it a mapper. This means that it would be far less efficient with small files, but potentially vastly more efficient with larger ones. Also, we wouldn't need a word list. One would be generated for every individual file and stored within it.
