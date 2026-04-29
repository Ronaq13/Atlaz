# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require "csv"

def clean_id(val)
  val.presence&.gsub(",", "")&.to_i
end

# ---------------------------------------------------------------------------
# Destinations
# ---------------------------------------------------------------------------
puts "Seeding destinations..."

destinations_csv = Rails.root.join("db", "seeds", "destinations_seed.csv")
rows = CSV.read(destinations_csv, headers: true)

# Maps original CSV id → newly created Destination record so that
# state_id / country_id (self-referential on the same table via STI)
# can be resolved to the correct new primary keys.
id_map = {}

[ "country", "state", "city" ].each do |klass|
  type_rows = rows.select { |r| r["type"] == klass }
  puts "  #{klass}: #{type_rows.size} rows"

  type_rows.each do |row|
    latitude  = row["latitude"].presence
    longitude = row["longitude"].presence
    next if latitude.nil? || longitude.nil?

    old_id      = clean_id(row["id"])
    old_state   = clean_id(row["state_id"])
    old_country = clean_id(row["country_id"])

    record = Destination.find_or_create_by!(
      type:       klass.capitalize,
      name:       row["name"].presence,
      latitude:   latitude.to_f,
      longitude:  longitude.to_f,
      state_id:   id_map[old_state]&.id,
      country_id: id_map[old_country]&.id
    )

    id_map[old_id] = record
  end
end

puts "Done! #{Destination.count} destinations seeded."

# ---------------------------------------------------------------------------
# Currencies
# ---------------------------------------------------------------------------
puts "Seeding currencies..."

currencies_csv = Rails.root.join("db", "seeds", "currencies_seed.csv")

CSV.foreach(currencies_csv, headers: true) do |row|
  Currency.find_or_create_by!(code: row["code"]) do |c|
    c.symbol = row["symbol"]
    c.name   = row["name"]
  end
end

puts "Done! #{Currency.count} currencies seeded."
