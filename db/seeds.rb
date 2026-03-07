# Create admin user if none exists
admin = User.find_or_create_by!(email_address: "brad@schoolai.com") do |u|
  u.name = "Brad"
  u.password = "changeme123"
  u.admin = true
  u.onboarding_completed = true
end

if admin.previously_new_record?
  puts "Admin user created: #{admin.email_address} (change password after first login!)"
else
  puts "Admin user already exists: #{admin.email_address}"
end

# Create invite code for friends
invite_code = InviteCode.find_or_create_by!(code: "FULLSEND2026") do |ic|
  ic.max_uses = 20
end
puts "Invite code for friends: #{invite_code.code}"

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

