def print_stage(stage)

  def stage1
    puts "[ ] Sorting the list by length"
  end

  def stage2
    puts "[x] Sorting the list by length"
    puts "[ ] Training the algorithm"
  end

  def stage3
    puts "[x] Sorting the list by length"
    puts "[x] Training the algorithm"
    puts "[ ] Removing the word rankings"
  end

  def stage4
    puts "[x] Sorting the list by length"
    puts "[x] Training the algorithm"
    puts "[x] Removing the word rankings"
    puts "[ ] Generating the mini-expressions"
  end

  def stage5
    puts "[x] Sorting the list by length"
    puts "[x] Training the algorithm"
    puts "[x] Removing the word rankings"
    puts "[x] Generating the mini-expressions"
    puts "\nReady!"
  end

  case stage
  when 1 then stage1
  when 2 then stage2
  when 3 then stage3
  when 4 then stage4
  when 5 then stage5
  end
end
