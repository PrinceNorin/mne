ApplicationRecord.transaction do
  categories = {
    'ថ្មសំណង់' => 50,
    'ខ្សាច់សំណង់' => 30,
    'អាចម៍ដី' => 30,
    'ខ្សាច់បក' => 30,
    'ដីក្រហម' => 30,
    'ថ្មអារ' => 50
  }

  categories.each do |name, rate|
    Category.create!(name: name, tax_rate: rate)
  end

  print 'Enter your name: '
  name = STDIN.gets.chomp

  print 'Enter your email: '
  email = STDIN.gets.chomp

  print 'Enter your password: '
  pass = STDIN.noecho(&:gets).chomp

  User.create!(name: name, email: email, password: pass)
end
