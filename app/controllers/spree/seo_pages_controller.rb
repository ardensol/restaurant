class Spree::GiftPagesController < Spree::StoreController
  before_action :set_seo_page, only: [:show]
 
  def show
  end

  def index
  	@seo_pages = Spree::SeoPage.all
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seo_page
      @seo_page = Spree::SeoPage.friendly.find(params[:id])
    end

  
end
