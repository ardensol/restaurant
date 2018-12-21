class AddSpreeImageColumns < ActiveRecord::Migration
  def change
    add_column :spree_assets, :s3_url, :string
  end
end
