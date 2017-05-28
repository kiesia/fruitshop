require 'optparse'
require './order'

PRODUCTS = %w(Rockmelon Watermelon Pineapple)
options = {}

OptionParser.new do |parser|
  products = PRODUCTS.map { |p| "#{p.downcase}s" }

  products.each do |product|
    parser.on("--#{product} COUNT", Integer, "Number of #{product} to purchase") do |val|
      options[product.to_sym] = val
    end
  end
end.parse!

order = Order.new options