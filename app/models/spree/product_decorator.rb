Spree::Product.class_eval do
  has_many :eel_images, dependent: :destroy, as: :viewable
end