# lib/tasks/cities_codes.rake
namespace :cities do
  desc "Sync Vietnam province/city MOET codes into cities.code"
  task sync_moet_codes: :environment do
    mapping = {
      "01" => "Hà Nội",
      "02" => "Hồ Chí Minh",
      "03" => "Hải Phòng",
      "04" => "Đà Nẵng",
      "05" => "Hà Giang",
      "06" => "Cao Bằng",
      "07" => "Lai Châu",
      "08" => "Lào Cai",
      "09" => "Tuyên Quang",
      "10" => "Lạng Sơn",
      "11" => "Bắc Kạn",
      "12" => "Thái Nguyên",
      "13" => "Yên Bái",
      "14" => "Sơn La",
      "15" => "Phú Thọ",
      "16" => "Vĩnh Phúc",
      "17" => "Quảng Ninh",
      "18" => "Bắc Giang",
      "19" => "Bắc Ninh",
      "21" => "Hải Dương",
      "22" => "Hưng Yên",
      "23" => "Hòa Bình",
      "24" => "Hà Nam",
      "25" => "Nam Định",
      "26" => "Thái Bình",
      "27" => "Ninh Bình",
      "28" => "Thanh Hóa",
      "29" => "Nghệ An",
      "30" => "Hà Tĩnh",
      "31" => "Quảng Bình",
      "32" => "Quảng Trị",
      "33" => "Thừa Thiên Huế",
      "34" => "Quảng Nam",
      "35" => "Quảng Ngãi",
      "36" => "Kon Tum",
      "37" => "Bình Định",
      "38" => "Gia Lai",
      "39" => "Phú Yên",
      "40" => "Đắk Lắk",
      "41" => "Khánh Hòa",
      "42" => "Lâm Đồng",
      "43" => "Bình Phước",
      "44" => "Bình Dương",
      "45" => "Ninh Thuận",
      "46" => "Tây Ninh",
      "47" => "Bình Thuận",
      "48" => "Đồng Nai",
      "49" => "Long An",
      "50" => "Đồng Tháp",
      "51" => "An Giang",
      "52" => "Bà Rịa – Vũng Tàu",
      "53" => "Tiền Giang",
      "54" => "Kiên Giang",
      "55" => "Cần Thơ",
      "56" => "Bến Tre",
      "57" => "Vĩnh Long",
      "58" => "Trà Vinh",
      "59" => "Sóc Trăng",
      "60" => "Bạc Liêu",
      "61" => "Cà Mau",
      "62" => "Điện Biên",
      "63" => "Đắk Nông",
      "64" => "Hậu Giang"
    }
    created = 0
    updated = 0
    mapping.each do |code, name|
      city = City.find_or_initialize_by(name: name)
      if city.code != code
        city.code = code
        city.save!
        city.previous_changes.key?("id") ? created += 1 : updated += 1
      end
    end

    puts "Cities synced. Created: #{created}, Updated: #{updated}"
    puts "Total mapped: #{mapping.size}"
  end
end
