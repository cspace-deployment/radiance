# frozen_string_literal: true
module ControllerLevelHelpers
  module ControllerViewHelpers
    include Blacklight::Facet

    def search_state
      @search_state ||= Blacklight::SearchState.new(params, blacklight_config, controller)
    end

    def blacklight_configuration_context
      @blacklight_configuration_context ||= Blacklight::Configuration::Context.new(controller)
    end

    def blacklight_config
      @blacklight_config ||= Blacklight::Configuration.new
    end

    def search_action_path(args)
      @search_action_path ||= search_action_url args
    end

    def search_action_url options = {}
      options = options.to_h if options.is_a? Blacklight::SearchState
      url_for(options.reverse_merge(action: 'catalog'))
    end

    def search_session
      @search_session ||= {}
    end

    def current_search_session
      @current_search_session
    end

    def default_search_field
      @default_search_field
    end

    def advanced_query
      @advanced_query
    end
  end

  def initialize_controller_helpers(helper)
    helper.extend ControllerViewHelpers
  end

  # Monkeypatch to fix https://github.com/rspec/rspec-rails/pull/2521
  def _default_render_options
    val = super
    return val unless val[:handlers]

    val.merge(handlers: val.fetch(:handlers).map(&:to_sym))
  end
end
