namespace :hyku_leaf do
  desc "Make users administrators. Supply a space separated list, eg ['person1@example.com person2@example.com']"
  task :make_me_admin, [:email] => [:environment] do |_t, args|
    if args[:email].nil?
      puts 'Supply a space separated list of email addresses, like this'
      puts "rake ulcc:make_me_admin['person1@example.com person2@example.com']"
    else
      args[:email].split(' ').each do |admin|
        if admin.include? '@'
          make_admin(admin)
        else
          puts "#{admin} is an invalid email address."
        end
      end
    end
  end

  desc "Invite users given in the supplied csv file_path. The csv must contain a header row and three columns: " \
        "email, display name, admin. The admin column should contain the word true if the user" \
        "should be made an administrator."
  task :invite_users, [:path] => [:environment] do |_t, args|
    if args[:path].nil?
      puts 'Supply the path to a csv file, like this'
      puts "rake ulcc:invite_users['/tmp/my_file.csv']"
      puts "the CSV file must contain a header row and three columns: email, display name, admin"
      puts "the admin column should contain the word true to indicate that the given user should be an admin"
    else
      begin
        process_csv(args[:path])
      rescue
        puts "The file, #{args[:path]}, does not exist or is invalid, please check the path is correct and make " \
        "sure the file is in the right format (comma separated)"
      end
    end
  end

  # private

  # Make the user an administrator
  def make_admin(email)
    user = User.find_by(email: email)
    if user.nil?
      puts "#{email} doesn't have a user account so cannot be made an admin."
    else
      user.add_role :admin
      puts "#{email} is now an admin."
    end
  end

  # Send an email invitation to the given user
  #
  # @param email [String] email address for the new user
  # @param display_name [String] display name for the new user
  # @param admin [Boolean] true if the new user should be made an admin
  def invite_user(email, name = nil, admin = false)
    display_name = name ? name : "User"
    if User.find_by(email: email).nil?
      user = User.invite!(email: email, display_name: display_name)
      user.add_role :admin if admin
      puts "#{email} was sent an email invitation and was#{admin ? '' : ' not'} made an admin"
    else
      puts "#{email} is already a user"
    end
  end

  # Read the csv and process each line
  #
  # @param csv [String] the path to a csv file
  def process_csv(csv)
    users = CSV.read(csv)
    users.shift # skip header row
    users.each do |line|
      validate_email(line)
    end
  end

  # Process a single line from the users csv
  #
  # @param line [Array] an array of data from the users csv
  def process_line(line)
    name = line[1].nil? ? nil : line[1].strip
    admin = true unless line[2].nil? && line[2] != "true"
    invite_user(line[0].strip, name, admin)
  end

  # Check that the first element in the array contains '@'
  #
  # @param line [Array] an array of data from the users csv
  def validate_email(line)
    if line[0].include? '@'
      process_line(line)
    else
      puts "#{line[0]} is not a valid email address, please check your data"
    end
  end
end
