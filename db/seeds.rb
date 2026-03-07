# Create initial access code for first user
access_code = InviteCode.find_or_create_by!(code: "FIRSTUSER") do |ic|
  ic.max_uses = 1
end
puts "Initial access code: #{access_code.code}"

# Create admin user if none exists
admin = User.find_by(email_address: "brad@schoolai.com")
if admin.nil?
  admin = User.create!(
    name: "Brad",
    email_address: "brad@schoolai.com",
    password: "changeme123",
    admin: true
  )
  puts "Admin user created: #{admin.email_address} (change password after first login!)"
  access_code.use!
else
  puts "Admin user already exists: #{admin.email_address}"
end

# Sync F1 data
puts "Syncing F1 data for #{Time.current.year}..."
begin
  service = F1SyncService.new
  service.sync_all(Time.current.year)
  
  # Add any missing drivers for 2026 grid
  add_missing_2026_drivers
  
  puts "F1 data synced successfully!"
  puts "  - Seasons: #{Season.count}"
  puts "  - Teams: #{Team.count}"
  puts "  - Drivers: #{Driver.count}"
  puts "  - Races: #{Race.count}"
rescue => e
  puts "Warning: F1 data sync failed: #{e.message}"
  puts "You can manually sync later from the admin panel."
end

def add_missing_2026_drivers
  missing_drivers = {
    "doohan" => { name: "Jack Doohan", code: "DOO", number: 7, team: "alpine" },
    "tsunoda" => { name: "Yuki Tsunoda", code: "TSU", number: 22, team: "rb" }
  }
  
  missing_drivers.each do |external_id, attrs|
    next if Driver.exists?(external_id: external_id)
    
    team = Team.find_by(external_id: attrs[:team])
    Driver.create!(
      external_id: external_id,
      name: attrs[:name],
      code: attrs[:code],
      number: attrs[:number],
      team: team
    )
    puts "  Added missing driver: #{attrs[:name]}"
  end
  
  # Remove drivers not on 2026 grid
  Driver.where(external_id: ["perez", "arvid_lindblad"]).destroy_all
end

# Create additional access codes for testing
5.times do
  code = InviteCode.create!(max_uses: 1)
  puts "Created access code: #{code.code}"
end
