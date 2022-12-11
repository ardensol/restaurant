class WebhooksController < ActionController::Base
  protect_from_forgery with: :null_session
  def sync
    Inventories::Sync.new.execute_single(params)

    p 'hello'

    head :ok
  end
end