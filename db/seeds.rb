print 'Enter your name: '
name = STDIN.gets.chomp

print 'Enter your email: '
email = STDIN.gets.chomp

print 'Enter your password: '
pass = STDIN.noecho(&:gets).chomp

User.create!(name: name, email: email, password: pass)
STDIN.print "\nA new user has been created!\n"
