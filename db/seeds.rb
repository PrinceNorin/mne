ApplicationRecord.transaction do
  categories = %w(
    ថ្ម
    អាចម៍ដី
    ថ្មអារ
    ខ្សាច់សំណង់
  )

  categories.each do |name|
    Category.create!(name: name)
  end

  print 'Enter your name: '
  name = STDIN.gets.chomp

  print 'Enter your email: '
  email = STDIN.gets.chomp

  print 'Enter your password: '
  pass = STDIN.noecho(&:gets).chomp

  User.create!(name: name, email: email, password: pass)
  STDIN.print "\nA new user has been created!\n"
end
