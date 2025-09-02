class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  before_action :alert_screen_reader

  private

  def alert_screen_reader
    sr_alert = search_state.params.delete(:sr_alert)
    if sr_alert
      flash[:sr_alert] = sr_alert
      redirect_to view_context.search_action_path(search_state)
    end
  end
end
