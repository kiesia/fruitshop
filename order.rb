class Order
  attr_accessor :order, :packed_order, :subtotals

  def initialize(options = {})
    validate! options
    @order = options
    @packed_order = {}
    @subtotals = {}
  end

  def process
    pack_order
    create_invoice
  end

  def pack_order
    @order.each do |line_item|
      product, amount = line_item
      pack_product product, amount
    end
    exit 1 if @has_incorrect_order_size
  end
  
  # placeholder code, don't judge me ;-)
  def pack_product(product, remainder)
    packs = get_product(product).packs
    @packed_order[product] = {}

    packs.keys.sort.reverse.each do |size|
      pack_count, remainder = remainder.divmod(size)
      @packed_order[product][size] = pack_count if pack_count > 0
    end

    incorrect_order_size(product) if remainder > 0
  end

  def create_invoice
    calculate_subtotals
    @packed_order.keys.each do |product|
      puts product_summary(product)
      puts pack_summary(product)
    end
    puts "TOTAL: #{format_money(calculate_total)}"
  end

  def calculate_subtotals
    @packed_order.keys.each do |product|
      subtotal = 0

      @packed_order[product].each do |pack, quantity|
        cost_per_pack = get_product(product).packs[pack]
        subtotal = subtotal + (quantity * cost_per_pack)
      end

      @subtotals[product] = subtotal
    end
  end

  def calculate_total
    @subtotals.values.reduce(0, :+)
  end

  def product_summary(product)
    output = []
    output << @order[product] # count
    output << product.to_s.capitalize # name
    output << format_money(@subtotals[product]) # subtotal
    output.join(" ")
  end

  def pack_summary(product)
    packs = get_product(product).packs
    output = []

    @packed_order[product].each do |pack, quantity|
      output << " - #{quantity} x #{pack} pack @ #{format_money(packs[pack])}"
    end

    output.join("\n")
  end

  private

  def format_money(amount)
    "$#{sprintf("%.2f", amount)}"
  end

  # convert plural :products key into a classname
  # e.g. :watermelons >> Product::Watermelon
  def get_product(product)
    Products.const_get(product[0...-1].capitalize)
  end

  def validate!(options)
    validate_presence options
    validate_count options
  end

  def validate_presence(options)
    if options.empty?
      puts "Empty order, try -h for available options"
      exit 1
    end
  end

  def validate_count(options)
    if options.values.include? 0
      puts "Please enter a number greater than 0"
      exit 1
    end
  end

  def incorrect_order_size(product)
    @has_incorrect_order_size = true
    output = []
    output << "Could not pack your #{product.to_s.capitalize}."
    output << "Please ensure product count fits within pack sizes."
    output << "Pack sizes: #{get_product(product).packs.keys.join(", ")}"
    puts output.join(" ")
  end
end
