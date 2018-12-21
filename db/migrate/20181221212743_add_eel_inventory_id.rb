class AddEelInventoryId < ActiveRecord::Migration
  def change
    add_column :spree_products, :eel_inventory_id, :string
    add_column :spree_products, :archived, :boolean, default: false, null: false

    add_index :spree_products, :eel_inventory_id
  end
end
