class EelImage < ActiveRecord::Base
  self.table_name = 'spree_assets'

  belongs_to :viewable, class_name: 'Spree::Product'
end