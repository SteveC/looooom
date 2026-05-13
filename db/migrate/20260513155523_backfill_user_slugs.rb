class BackfillUserSlugs < ActiveRecord::Migration[8.1]
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    MigrationUser.reset_column_information

    MigrationUser.where(slug: nil).find_each do |user|
      base = user.name.presence || user.email.to_s.split("@").first.presence || "user"
      slug_base = base.parameterize.presence || "user"
      slug = slug_base
      suffix = 2

      while MigrationUser.where.not(id: user.id).exists?(slug: slug)
        slug = "#{slug_base}-#{suffix}"
        suffix += 1
      end

      user.update_columns(slug: slug)
    end
  end

  def down
    MigrationUser.update_all(slug: nil)
  end
end
