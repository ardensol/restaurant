class WebhooksController < ApplicationController
  def sync
    Inventories::Sync.new.execute_single(params)
  end
end