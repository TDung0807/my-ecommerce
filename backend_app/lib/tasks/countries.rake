# lib/tasks/countries.rake
namespace :countries do
  desc "Ensure Vietnam exists with ISO country_code 'VN'"
  task seed_vietnam: :environment do
    vn = Country.find_or_initialize_by(name: "Vietnam")
    vn.country_code = "VN"
    if vn.new_record?
      vn.save!
      puts "✅ Created Vietnam (VN)"
    else
      if vn.changed?
        vn.save!
        puts "✅ Updated Vietnam (VN)"
      else
        puts "ℹ️ Vietnam already present with code=#{vn.country_code}"
      end
    end
  end
end
