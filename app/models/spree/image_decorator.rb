Spree::Image.class_eval do
  before_validation -> { self.image_content_type = Paperclip.verify_mime_type(self, 'attachment') }

  has_attached_file :attachment,
                    validate_media_type: false,
                    styles: { mini: '48x48>', small: '100x100>', product: '240x240>', large: '600x600>' },
                    default_style: :product,
                    url: '/spree/products/:id/:style/:basename.:extension',
                    path: ':rails_root/public/spree/products/:id/:style/:basename.:extension',
                    convert_options: { all: '-strip -auto-orient -colorspace sRGB' }

  do_not_validate_attachment_file_type :attachment
  # validates_attachment :attachment,
  #                      :presence => true,
  #                      :content_type => { :content_type => %w(application/octet-stream image/jpeg image/jpg image/png image/gif) }
end