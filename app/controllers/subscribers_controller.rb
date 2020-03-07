class SubscribersController < Spree::StoreController
  EEL_BASE_URL = 'https://eel-inventory.herokuapp.com'.freeze
  def create
    redirect_to(new_subscriber_path, notice: 'Invalid Email') and return unless subscriber_params[:email] =~ Devise.email_regexp

    p subscriber_params[:email] =~ Devise.email_regexp

    @response = post_updates

    p @response
    redirect_to root_path, notice: 'Successfully Subscribed'
  end

  def new

  end

  private

  def post_updates
    byebug
    HTTParty.post(
      "#{EEL_BASE_URL}/api/v1/subscribers",
      headers: {
        'Content-Type' => 'application/json'
      },
      params: {
        subscriber: subscriber_params.to_h
      }
    )
  end

  def subscriber_params
    params.require(:subscriber).permit(:email, :name, :notes, :subscription_type, category_ids: [])
  end
end