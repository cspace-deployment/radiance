require 'uri'

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  before_action :alert_screen_reader

  private

  def alert_screen_reader
    sr_alert = search_state.params.delete(:sr_alert)
    focus_target = search_state.params.delete(:focus_target)
    unless sr_alert.blank?
      flash[:sr_alert] = CGI.unescape(sr_alert)
    end
    unless focus_target.blank?
      flash[:focus_target] = CGI.unescape(focus_target)
    end
    unless sr_alert.blank? && focus_target.blank?
      redirect_to view_context.search_action_path(search_state)
    end
  end

  # Method used by sessions controller to sign out a user. You can overwrite
  # it in your ApplicationController to provide a custom hook for a custom
  # scope. Notice that differently from +after_sign_in_path_for+ this method
  # receives a symbol with the scope, and not the resource.
  #
  # By default it is the root_path.
  def after_sign_out_path_for(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    router_name = Devise.mappings[scope].router_name
    context = router_name ? send(router_name) : self
    # Redirect back to the page the user was on when they logged out, if possible
    uri = URI(request.referrer)
    referrer_path = unless uri.path == '/users/edit' then uri.path else nil end
    referrer_path || (context.respond_to?(:root_path) ? context.root_path : "/")
  end
end
