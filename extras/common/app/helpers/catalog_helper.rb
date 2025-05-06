module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  ##
  # Render the view type icon for the results view picker
  #
  # @deprecated
  # @param [String] view
  # @return [String]
  def render_view_type_group_icon view
    blacklight_icon(view, aria_hidden: true, label: false)
  end
  deprecation_deprecate render_view_type_group_icon: 'call blacklight_icon instead'

  ##
  # Render a <title> appropriate string for a set of search parameters
  # @param [ActionController::Parameters] params
  # @return [String]
  def render_search_to_page_title(search_state_or_params)
    search_state = if search_state_or_params.is_a? Blacklight::SearchState
                     search_state_or_params
                   else
                     controller.search_state_class.new(params, blacklight_config, self)
                   end

    constraints = []

    if search_state.query_param.present?
      q_label = label_for_search_field(search_state.search_field.key) unless search_state.search_field&.key.blank? || default_search_field?(search_state.search_field.key)

      constraints += if q_label.present?
                       [t('blacklight.search.page_title.constraint', label: q_label, value: search_state.query_param)]
                     else
                       [search_state.query_param]
                     end
    end

    if search_state.filters.any?
      constraints += search_state.filters.collect { |filter| render_search_to_page_title_filter(filter.key, filter.values) }
    end

    strip_tags(constraints.join(' / '))
  end

end
