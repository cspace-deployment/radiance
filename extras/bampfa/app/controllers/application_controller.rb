class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  before_action :alert_screen_reader

  private

  def alert_screen_reader
    sr_alert = request.parameters.delete(:sr_alert)
    focus_target = request.parameters.delete(:focus_target)
    unless sr_alert.blank?
      flash[:sr_alert] = CGI.unescape(sr_alert)
    end
    unless focus_target.blank?
      flash[:focus_target] = CGI.unescape(focus_target)
    end
    unless sr_alert.blank? && focus_target.blank?
      redirect_to request.parameters
    end
  end
end
