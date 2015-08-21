class Spree::SeoPage < ActiveRecord::Base
	extend FriendlyId
	friendly_id :name, use: :slugged
	has_attached_file :article_image, :styles => { :medium => "576x414>"}, :default_url => "/images/:style/missing.png"
  	validates_attachment_content_type :article_image, :content_type => /\Aimage\/.*\Z/
end
