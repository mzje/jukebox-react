puts "Please enter a login to create a new user (or leave blank to skip)..."
login = $stdin.gets.chomp
if login.present?
  test_user = User.where(:login => login).first_or_initialize
  if test_user.new_record?
    puts "Please enter an email..."
    email = $stdin.gets.chomp
    puts "Please enter a password..."
    password = $stdin.gets.chomp
  	test_user.name = login
  	test_user.email = email
  	test_user.password = password
  	test_user.password_confirmation = password
  	test_user.nickname = "TEST"
  	test_user.save
  end
end
