ApplicationRecord.transaction do
  categories = %w(
    ថ្ម
    ថ្មអារ
    អាចម៍ដី
    ដីក្រហម
    ខ្សាច់
    ខ្សាច់បក
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
end
