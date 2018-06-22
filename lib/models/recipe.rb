require 'pry'
class Recipe < ActiveRecord::Base
  belongs_to :template_recipe
  belongs_to :user
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients
  has_one :nutrition_fact

  delegate :avg_cooking_time, to: :template_recipe

  after_create :set_attributes

  #INITIALIZATION METHODS

  def set_attributes
    self.template_recipe = TemplateRecipe.all.sample
    get_ingredients
    generate_nutrition_data
    get_nutrition_data
    self.name = self.generate_name
    update_ingredient_quantity
    instructions
    self.save
  end

  def get_ingredient_by_type(ingredient_type)
    Ingredient.all.select { |ing| ing.category == ingredient_type }.sample
  end

  def generate_recipe_ingredient_X_times(category, number)
    number.times do
      generate_recipe_ingredient(category)
    end
  end

  def generate_string_from_relevant_ingredients
    names =  self.ingredients.map do |ingredient|
      ingredient.name
    end
    names[-3 .. -2].join(", ") + ", and " + names[-1]
    # .tap{|s| s[s.rindex(', '), 2] = ' and '}
  end

  def generate_name
    "#{generate_string_from_relevant_ingredients} #{template_recipe.meal}"
  end

  def generate_recipe_ingredient(category)
    ingredient = get_ingredient_by_type(category)
    if self.recipe_ingredients.any? { |e| e.ingredient_id == ingredient.id }
      generate_recipe_ingredient(category)

    else
      RecipeIngredient.create(recipe: self, ingredient: ingredient)
      self.recipe_ingredients = Recipe.find(self.id).recipe_ingredients
    end
  end

  def get_ingredients
    requirements = JSON.parse(self.template_recipe.ingredient_requirement)
    grain_amount = requirements["grains"]
    protein_amount = requirements["proteins"]
    veg_amount = requirements["veg"]

    requirements["base_ingredients"].each do |ing|
      ingredient = Ingredient.find_by(name: ing)
      RecipeIngredient.create(recipe: self, ingredient: ingredient)
    end

    generate_recipe_ingredient_X_times("grain", grain_amount)
    generate_recipe_ingredient_X_times("protein", protein_amount)
    generate_recipe_ingredient_X_times("veg", veg_amount)
  end

  def generate_nutrition_data
    NutritionFact.create({:recipe_id => self.id})
  end

  def get_nutrition_data

    nutrition_fact.set_total_macros
    nutrition_fact.save
    {
      protein: nutrition_fact.protein,
      carbs: nutrition_fact.carbs,
      fat: nutrition_fact.fat
    }
  end

  def update_ingredient_quantity
    self.ingredients.each do |ingredient|
      i = self.ingredients.index(ingredient)
      nutrition_fact.set_ingredient_measurments(ingredient, i)
      ingredient.save
    end
  end

  def get_ingredient_name_by_category(ing_cat)
    x = self.ingredients.find do |ingredient|
      ingredient.category == ing_cat
    end
    " #{x.name.downcase} "
  end

  def instructions
    instructions = self.template_recipe.instructions.dup
    instructions.gsub!(/(^|\W)grain($|\W)/, get_ingredient_name_by_category("grain"))
    instructions.gsub!(/(^|\W)protein($|\W)/, get_ingredient_name_by_category("protein"))
    self.instructions = instructions
  end

end
