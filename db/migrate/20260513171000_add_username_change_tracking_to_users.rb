class AddUsernameChangeTrackingToUsers < ActiveRecord::Migration[8.1]
  ADJECTIVES = %w[brave bright calm clever heavy quick steady].freeze
  NOUNS = %w[banana harbor lantern meadow rocket summit].freeze

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    add_column :users, :username_changed_at, :datetime

    MigrationUser.reset_column_information
    MigrationUser.where(slug: [ nil, "" ]).find_each do |user|
      user.update_columns(slug: unique_username_for(user))
    end

    change_column_null :users, :slug, false
  end

  def down
    change_column_null :users, :slug, true
    remove_column :users, :username_changed_at
  end

  private

  def unique_username_for(user)
    loop do
      candidate = "#{ADJECTIVES.sample}-#{NOUNS.sample}-#{rand(10..99)}"
      return candidate unless MigrationUser.where.not(id: user.id).exists?(slug: candidate)
    end
  end
end
