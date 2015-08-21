  module Spree
  module Admin
    class SeoPagesController < Spree::Admin::BaseController
      before_action :set_seo_page, only: [:edit, :destroy, :update]    

      def index
        @seo_pages = SeoPage.all.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def new
        @seo_page = SeoPage.new
      end

      def create
        @seo_page = SeoPage.new(seo_page_params)
        if @seo_page.save
          flash[:notice] = "Subscription Coupon created succesfully."
          redirect_to edit_admin_seo_page_url(@seo_page)
        else
          render :new
        end
      end

      def update
	    respond_to do |format|
	      if @seo_page.update(seo_page_params)
	        format.html { redirect_to edit_admin_seo_page_path(@seo_page), notice: 'SeoPage was successfully updated.' }
	        format.json { head :no_content }
	      else
	        format.html { render action: 'edit' }
	        format.json { render json: @seo_page.errors, status: :unprocessable_entity }
	      end
	    end
	  end

  	  def edit
  	  end


  	  def destroy
  	    @seo_page.destroy

  	    respond_to do |format|
  	      format.html { redirect_to admin_seo_pages_url }
  	    end
  	  end

      private
      def set_seo_page
        @seo_page = SeoPage.friendly.find(params[:id])
      end

  	  def seo_page_params
  	    params.require(:seo_page).permit(:h1_text, :h2_text, :og_description, :slug, :article_image, :article_header, :paragraph_text, :name)
  	  end

    end
  end
end