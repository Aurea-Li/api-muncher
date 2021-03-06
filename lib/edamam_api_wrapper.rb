require 'httparty'

class EdamamApiWrapper
  BASE_URL = "https://api.edamam.com/search?"
  ID = ENV["RECIPE_ID"]
  TOKEN = ENV["RECIPE_TOKEN"]
  TOKENS_URL = "&app_id=#{ID}&app_key=#{TOKEN}"


  def self.search_recipes(query)
    url = BASE_URL + "q=#{query}" + TOKENS_URL

    responses = HTTParty.get(url)["hits"]

    recipes = responses.map do |response|
      create_recipe(response["recipe"])
    end

    return recipes

  end

  def self.find_recipe(uri)

    encoded_uri = URI.encode_www_form_component(uri)
    url = BASE_URL + "r=#{encoded_uri}" + TOKENS_URL

    response = HTTParty.get(url)

    if response_valid?(response)
      return create_recipe(response[0])
    else
      return nil
    end
  end

  private

  def self.create_recipe(api_params)

    ingredients = api_params["ingredients"].map do |ing_hash|
      ing_hash["text"]
    end

    return Recipe.new(
      api_params["label"],
      api_params["image"],
      api_params["uri"],
      {
        dietary_information: api_params["dietLabels"],
        ingredients: ingredients,
        link: api_params["url"]
      }
    )
  end

  def self.response_valid?(response)
    return response.to_s.length > 10
  end
end
