Spree::Image.class_eval do
  before_validation -> { self.attachment_content_type = Paperclip.verify_mime_type(self, 'attachment') }

  p "LOADED IMAGE CLASS EVAL"

end