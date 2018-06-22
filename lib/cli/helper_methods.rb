require 'pry'
#LOGIN MENU
def start_menu
  puts "\n                1. Login".yellow
  puts "               2. Sign up".yellow
  puts "                3. Exit\n".yellow
end

#MAIN MENU
def display_image
  puts "                     \\     /"
  puts "                     \\\\   //"
  puts "                      )\\-/("
  puts "                      /e e\\ "
  puts "                     ( =Y= )"
  puts "                     /`-!-'\\ "
  puts "        ___\\ \\".light_red + "      /       \\"
  puts " \\".light_green + "   /    ```  --```~~\"--.,__".light_red + "\\"
  puts " `-._".light_green + "\\ /                       `~~\"--.,_".light_red
  puts " ----->".light_green + "|                                `~~\"--.,_".light_red
  puts " _.-'".light_green + "/ \\                                         ~~\"--.,_".light_red
  puts "     \\_________________________,,,,....----\"\"\"\"~~~~````".light_red
end

def main_menu
  puts "\n  How can I help you:".cyan
  puts "\n             1. Generate New Recipe".yellow
  puts "             2. Browse Recipe Book".yellow
  puts "                   3. Help".yellow
  puts "                   4. Exit".yellow
end

#1 - RECIPE GENERATOR
def generate_recipe(user)
  recipe = Recipe.create
  display_recipe(recipe)
  puts "\nWould you like to add this recipe to your Recipe Book? (Y/N)".cyan
  loop do
    input = gets.strip.downcase

    if input == "y" || input == "yes"
      PersonalRecipe.create(template_recipe_id: recipe.template_recipe_id, user_id: user.id)
      system("clear")
      puts "   - - - - - - - - - - - - - - - - - - - - - - - - - - - -".green
      puts "      The recipe has been added to your Recipe Book!".green
      puts "   - - - - - - - - - - - - - - - - - - - - - - - - - - - -".green
      break
    elsif input == "n" || input == "no"
      system("clear")
      break
    else
      puts "I'm sorry, but I need a 'Yes'('Y') or a 'No'('N')".red
    end
  end
end


#Calculate quantity based on user input for amount of portions

def get_portions(ingredients, num_of_portions)
  ingredients_quantities = ingredients.map do |ingredient|
    quantity = (ingredient.quantity.to_f / 2 * num_of_portions.to_i).to_f.round(2)
    unit = ingredient.serving_unit
    "#{quantity} #{unit}"
  end
  ingredients_quantities
end

def prompt_for_portions
  loop do
    puts "How many people are you cooking for?".light_black
    input = gets.strip
    if ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"].include?(input)
      system("clear")
      return input
    else
      puts " Invalid command. Please try again.".magenta
    end
  end
end

def display_recipe(recipe)
  system("clear")
  instructions = JSON.parse(recipe.instructions)
  ingredients = recipe.ingredients
  num_of_portions = prompt_for_portions
  ingredient_quantity = get_portions(ingredients, num_of_portions)
  nutrition = NutritionFact.find_by(recipe_id: recipe.id)
  puts "\n        - - -".red + " #{recipe.name}".green + " - - -".red
  puts "\n  INGREDIENTS:\n".yellow
  ingredients.each do |ing|
    i = ingredients.index(ing)
    puts " o #{ing.name} #{ingredient_quantity[i]}"
  end
  puts "\n  INSTRUCTIONS:\n".yellow
  instructions.each do |step, instruction|
    puts " #{step} - #{instruction}"
  end
  puts "\n  NUTRITIONAL FACTS:".yellow
  print " Carbohydates: #{nutrition[:carbs]}g //"
  print " Protein: #{nutrition[:protein]}g //"
  puts " Fats: #{nutrition[:fat]}g"
end

#2 - RECIPE BOOK
def recipe_book(user)
  system("clear")
  book = PersonalRecipe.all.select do |p_r|
    p_r.user == user
  end
  loop do
    puts "\n~ ~ ~ ~ ~ ~ ~ ~ ~".red + " RECIPE BOOK".green + " ~ ~ ~ ~ ~ ~ ~ ~ ~\n\n".red
    book.each_with_index do |recipe, index|
      puts " #{index + 1}. #{recipe.name}".yellow
    end
    puts " 0. Close Recipe Book".yellow
    puts "\n Enter the NUMBER for the recipe you'd like to see:".light_black
    input = gets.strip.to_i
    recipe = book[input - 1]

    if input == 0
      system("clear")
      break

    elsif input <= book.length
      display_recipe(recipe)
      puts "\n What would you like to do with this recipe?".cyan
      puts "  1. Edit recipe's name".yellow
      puts "  2. Remove recipe from Recipe Book".yellow
      puts "  3. Go back to Recipe Book".yellow
      puts "  4. Return to Main Menu".yellow
      puts "\n Enter the number or the first word of a command:".light_black
      input2 = gets.strip.downcase

      case input2
      when "1", "edit" then
        puts "\n Current recipe name:".light_red + " #{recipe.name}"
        print " New recipe name: ".light_green
        recipe.name = gets.strip
        recipe.save
      when "2", "remove" then
        system("clear")
        recipe.destroy
        book = PersonalRecipe.all.select do |p_r|
          p_r.user == user
        end
        puts "\n   - - - - - - - - - - - - - - - -".green
        puts "    The recipe has been deleted".green
        puts "   - - - - - - - - - - - - - - - -\n".green
      when "3", "go" then
        recipe_book(user)
        break
      when "4", "return" then
        system("clear")
        break
      else
        puts "Invalid command. Please try again.".magenta
      end
    else
      puts " Please enter a number between 0 and #{book.length}."
      recipe_book(user)
      break
    end
  end
end

#3 - HELP INFORMATION
def help_info
  system("clear")
  puts "\n Help - Shows information about commands".green
  puts "\n 1 . Generate New Recipe".yellow
  puts "       Creates a new recipe using random ingredients.".yellow
  puts "       This recipe can then be saved to your Recipe Book.".yellow
  puts "\n 2 . Browse Recipe Book".yellow
  puts "       Browse your collection of saved recipes.".yellow
  puts "\n 4 . Exit".yellow
  puts "       Exit the program, discarding any unsaved recipes.".light_yellow
end

#RUN PROGRAM
def run
  system("clear")
  puts "\n\n/\\/\\/\\/\\/\\".light_red + " - VEGAN GENERATOR - ".green + "/\\/\\/\\/\\/\\".light_red
  user = nil
  loop do
    start_menu
    puts "\n Enter a command or number:".light_black
    input = gets.strip.downcase
    system("clear")
    case input

    when "1", "login"
      puts "\n      L O G I N\n\n".green
      print " Username: "
      username = gets.strip

      if User.find_by(username: username)
        print " Password: "
        password = gets.strip

        if User.find_by(username: username).password == password
          user = User.find_by(username: username)
          break
        else
          system("clear")
          puts "   - - - - - - - - - - - - - - - - - -".red
          puts "   - X - X - Wrong password - X - X -".red
          puts "   - - - - - - - - - - - - - - - - - -".red
        end

      else
        system("clear")
        puts "- - - - - - - - - - - - - - - - - - - - - - - -".red
        puts "- X - X - That account doesn't exist - X - X -".red
        puts "- - - - - - - - - - - - - - - - - - - - - - - -".red
      end

    when "2", "sign up"
      puts "\n      S I G N   U P\n\n".green
      print " Username: "
      username = gets.strip

      if User.find_by(username: username)
        system("clear")
        puts "\n - X - X - That account already exists - X - X -\n"
      elsif username.empty?
        system("clear")
        puts "\n Username must have at least 1 character"
      else
        print " Password: "
        password = gets.strip
        User.create(username: username, password: password)
        system("clear")
        puts "\n      - - - - - - - - - - - - - - - -".green
        puts "      New account succesfully created".green
        puts "      - - - - - - - - - - - - - - - -\n".green
      end

    when "3", "exit"
      puts "      Goodbye!\n"
      break
    else
      puts "Invalid command. Please try again.".magenta
    end
  end

  if user != nil
    system("clear")
    puts "\n Welcome User! I'll be your Recipe Rabbit for today!\n\n".cyan
    display_image
    loop do
      main_menu
      puts "\n Enter the number or the first word of a command:".light_black
      input = gets.strip.downcase
      case input

      when "1", "generate" then
        puts " - / - \\ - Fetching Data - / - \\ -".magenta
        generate_recipe(user)

      when "2", "browse" then recipe_book(user)

      when "3", "help" then help_info

      when "4", "exit" then
        system("clear")
        puts "\n Catch you later, doc!\n\n".light_red
        break

      else
        puts "Invalid command. Please try again.".magenta
      end
    end
  end
end
