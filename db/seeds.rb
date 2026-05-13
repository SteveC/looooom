# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if ENV["ADMIN_EMAIL"].present?
  admin = User.find_by(email: ENV.fetch("ADMIN_EMAIL"))

  if admin
    admin.update!(name: admin.name.presence || ENV.fetch("ADMIN_NAME", "loom Admin"), admin: true)
  else
    Rails.logger.info("Admin email configured; matching Google user will be promoted on first sign-in.")
  end
end
