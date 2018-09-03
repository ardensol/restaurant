# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  config.layout = 'spree/layouts/spree_application'

  attachment_config = {
    s3_credentials: {
      access_key_id: ENV.fetch("S3_ACCESS_KEY"),
      secret_access_key: ENV.fetch("S3_SECRET"),
      bucket: ENV.fetch("S3_BUCKET"),
    },

    storage:        :s3,
    s3_headers:     { "Cache-Control" => "max-age=31557600" },
    s3_protocol:    "https",
 	bucket:         ENV.fetch("S3_BUCKET"),

    styles: {
      mini:     "95x95>",
      small:    "100x100>",
      product:  "320",
      large:    "360x360>",
      xlarge:   "555x555>"
    },

    path:          ":rails_root/public/spree/products/:id/:style/:basename.:extension",
    default_url:   "/spree/products/:id/:style/:basename.:extension",
    default_style: "product",
  }

  attachment_config.each do |key, value|
    Spree::Image.attachment_definitions[:attachment][key.to_sym] = value
  end
end

Spree.user_class = "Spree::User"



Spree::StaticContentController.class_eval do
  def show
    path = case params[:path]
           when Array
             params[:path].join("/")
           when String
             params[:path]
           when nil
             request.path
           end
    unless @page = Spree::Page.visible.where('slug = ? OR slug = ?', path, "/" + path).first
      render_404
    end
  end
end