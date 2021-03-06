require "open-uri"
require 'json'
require 'nokogiri'
require 'pry'

def line
  puts "-------------------------------------"
end

def dots
  puts "............."
end

EMOJI = ["๐", "๐", "๐ค", "๐ช", "๐", "๐", "๐ฆพ"].freeze

random_reviews = [
  {
    rating: 1,
    content: "Horrible, it ate my carpet when I wasn't home!"
  },
  {
    rating: 5,
    content: "I loved it, best pokemon ever!"
  },
  {
    rating: 4,
    content: "Amazing, was expecting it to be a bit better but I really enjoyed it."
  },
]

pokemons = ['pikachu', 'charmander', 'bulbasaur', 'squirtle']
locations = ['forest', 'lake']

puts "Deleting database..."
Review.destroy_all
Booking.destroy_all
Pokemon.destroy_all
User.destroy_all
puts "Done deleting database โ"

line
puts "๐ฅ Creating users "
ash = User.create!(email: "ash@pokemon.com", password: "password", nickname: "Ash")
gary = User.create!(email: "gary@pokemon.com", password: "password", nickname: "Gary")
puts "๐ฅ Done creating users โ"
line

puts "๐จโ๐ฌ Creating new pokemons... ๐ฉโ๐ฌ"
pokemons.each do |pokemon_name|
  # Getting pokemon name and type
  poke_info_url = "https://pokeapi.co/api/v2/pokemon/#{pokemon_name.downcase}"

  pokemon_serialized = open(poke_info_url).read
  pokemon = JSON.parse(pokemon_serialized)

  # Go to next if it's already created
  puts "Creating *#{pokemon['species']['name'].capitalize}* ๐งช"
  puts "- Type: #{pokemon['types'][0]['type']['name'].capitalize}"

  # Getting pokemon description
  poke_description_url = "https://www.pokemon.com/us/pokedex/#{pokemon['species']['name']}"

  html_file = open(poke_description_url).read
  html_doc = Nokogiri::HTML(html_file)

  pokemon_description = html_doc.search('.version-x.active')[0].text.strip

  # Creating new pokemon object
  new_pokemon = Pokemon.new(
    name: pokemon['species']['name'],
    description: pokemon_description,
    price: (rand(45..250)),
    location: locations.sample,
    user: User.all.sample
  )

  # Getting pokemon photo and attaching it to pokemon instance
  pokemon_id = pokemon["id"].to_s.rjust(3, "0")

  pokemon_photo_url = "https://assets.pokemon.com/assets/cms2/img/pokedex/full/#{pokemon_id}.png"
  pokemon_photo = URI.open(pokemon_photo_url)
  new_pokemon.photo.attach(io: pokemon_photo, filename: "#{pokemon["species"]["name"]}.png", content_type: 'image/png')


  puts "โ #{new_pokemon.name.capitalize} created! #{EMOJI.sample} - Total actual pokemons: #{Pokemon.count}" if new_pokemon.save!
  line
  sleep(3)
end

puts "Creating bookings and reviews for all pokemons"
Pokemon.all.each do |pokemon|
  start_date = Date.today - rand(45..250)
  end_date = start_date + rand(2..20)
  user = User.all.sample

  booking = Booking.create!(
    start_date: start_date,
    end_date: end_date,
    pokemon: pokemon,
    user: user
  )
  # TODO: Randomize this to be between accepted and declined
  booking.accepted!
  puts "โ Booking created: #{user.nickname.capitalize} booked #{pokemon.name.capitalize} from #{start_date} to #{end_date}."

  review = Review.new(random_reviews.sample)
  review.booking = booking
  review.save!
  puts "    โ #{user.nickname.capitalize} reviewed this booking with a #{review.rating}"
  line
end

puts "Total pokemons ๐ถ: #{Pokemon.count}"
puts "Total users ๐ฅ: #{User.count}"
puts "Total bookings ๐งพ: #{Booking.count}"
puts "Total reviews ๐ฃ: #{Review.count}"