class SpreeSeoPage < ActiveRecord::Migration
  def change
  	create_table :spree_seo_pages do |t|
      t.string :h1_text
      t.string :h2_text
      t.string :og_description
      t.string :slug
      t.attachment :article_image
      t.string :article_header
      t.text   :paragraph_text
      
      t.timestamps
    end
  end
end
