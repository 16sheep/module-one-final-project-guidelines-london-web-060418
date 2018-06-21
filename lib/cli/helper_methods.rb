#LOGIN MENU
def start_menu
  puts "\n                1. Login"
  puts "               2. Sign up"
  puts "                3. Exit\n"
end

#MAIN MENU
def display_image
  puts "                     \\     /"
  puts "                     \\\\   //"
  puts "                      )\\-/("
  puts "                      /e e\\ "
  puts "                     ( =Y= )"
  puts "                     /`-!-'\\ "
  puts "        ___\\ \\      /       \\"
  puts " \\   /    ```  --```~~\"--.,__\\"
  puts " `-._\\ /                       `~~\"--.,_"
  puts " ----->|                                `~~\"--.,_"
  puts " _.-'/ \\                                         ~~\"--.,_"
  puts "     \\_________________________,,,,....----\"\"\"\"~~~~````"
end

def main_menu
  display_image
  puts "\n  How can I help you:"
  puts "\n             1. Generate New Recipe"
  puts "             2. Browse Recipe Book"
  puts "                   3. Help"
  puts "                   4. Exit"
end

#1 - RECIPE GENERATOR
def generate_recipe
  recipe = Recipe.create
  display_recipe(recipe)
  puts "\nWould you like to add this recipe to your Recipe Book? (Y/N)"
  loop do
    input = gets.strip.downcase

    if input == "y" || input == "yes"
      PersonalRecipe.create(template_recipe_id: recipe.template_recipe_id)
      puts "   - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
      puts "\n  The recipe has been added to your Recipe Book!\n"
      puts "   - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
      break
    elsif input == "n" || input == "no"
      puts "\nBon appetit!\n"
      break
    else
      puts "I'm sorry, but I need a 'Yes'('Y') or a 'No'('N')"
    end
  end
end

def display_recipe(recipe)
  instructions = JSON.parse(recipe.instructions)
  ingredients = recipe.ingredients
  puts "        - - - PLACEHOLDER - - -"
  puts "\n  INGREDIENTS:\n"
  ingredients.each do |ing|
    puts "o #{ing.name}"
  end
  puts "\n  INSTRUCTIONS:\n"
  instructions.each do |step, instruction|
    puts "#{step} - #{instruction}"
  end
end

#2 - RECIPE BOOK
def recipe_book(user)
  book = PersonalRecipe.all.select do |p_r|
    p_r.user == user
  end
end

#3 - HELP INFORMATION
def help_info
  puts "\nHelp - Shows information about commands"
  puts "\n1 . Generate New Recipe"
  puts "      Creates a new recipe using random ingredients."
  puts "      This recipe can then be saved to your Recipe Book."
  puts "\n2 . Browse Recipe Book"
  puts "      Browse your collection of saved recipes."
  puts "\n4 . Exit"
  puts "      Exit the program, discarding any unsaved recipes."
end

#RUN PROGRAM
def run
  puts "\n/\\/\\/\\/\\/\\ - VEGAN GENERATOR - /\\/\\/\\/\\/\\"
  user = nil
  loop do
    start_menu
    puts "\nEnter a command or number:"
    input = gets.strip.downcase
    case input

    when "1", "login"
      puts "\n      L O G I N\n\n"
      print " Username: "
      username = gets.strip

      if User.find_by(username: username)
        print " Password: "
        password = gets.strip

        if User.find_by(username: username).password == password
          user = User.find_by(username: username)
          break
        else
          puts "   - - - - - - - - - - - - - - - - - -"
          puts "   - X - X - Wrong password - X - X -"
          puts "   - - - - - - - - - - - - - - - - - -"
        end

      else
        puts "   - - - - - - - - - - - - - - - - - - - - - - - -"
        puts "   - X - X - That account doesn't exist - X - X -"
        puts "   - - - - - - - - - - - - - - - - - - - - - - - -"
      end

    when "2", "sign up"
      puts "\n      S I G N   U P\n\n"
      print " Username: "
      username = gets.strip
      if User.find_by(username: username)
        puts "\n - X - X - This account already exists - X - X -\n"
      else
        print " Password: "
        password = gets.strip
        User.create(username: username, password: password)
        puts "\n   - - - - - - - - - - - - - - - -"
        puts "   New account succesfully created"
        puts "   - - - - - - - - - - - - - - - -\n"
      end

    when "3", "exit"
      puts "      Goodbye!\n"
      break
    else
      puts "Invalid command. Please try again."
    end
  end

  if user != nil
    puts "\nWelcome User! I'll be your Recipe Rabbit for today!\n\n"
    main_menu
    loop do
      puts "\nEnter the number or the first word of a command:"
      input = gets.strip.downcase
      case input

      when "1", "generate" then
        generate_recipe
        main_menu

      when "2", "browse" then recipe_book(user)

      when "3", "help" then help_info

      when "4", "exit" then
        puts "\n Catch you later, doc!\n\n"
        break

      else
        puts "Invalid command. Please try again."
      end
    end
  end
end
