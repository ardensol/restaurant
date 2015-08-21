class Addnametoseopage < ActiveRecord::Migration
  def change
  	add_column :spree_seo_pages, :name, :string
  end
end
