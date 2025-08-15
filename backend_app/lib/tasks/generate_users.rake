# lib/tasks/generate_users.rake
namespace :users do
  desc "Generate 10 random users and cache them in Redis"
  task generate_10: :environment do
    redis_service = RedisCache::Users.new  # <-- updated

    10.times do |i|
      email = "testuser#{i + 1}@example.com"
      password = "password123"

      user = User.create!(
        email: email,
        password: password,
        password_confirmation: password
      )

      redis_service.cache_on_register(user)
      puts "✅ Created & cached user: #{email}"
    end

    puts "🎉 Done generating and caching 10 users!"
  end
end
