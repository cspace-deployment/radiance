# frozen_string_literal: true

# Includes methods for rendering more textually on Search History page
# (render_search_to_s(_*))
module SearchHistoryConstraintsHelper
  include Blacklight::SearchHistoryConstraintsHelperBehavior
  include BlacklightAdvancedSearch::RenderConstraintsOverride

  # Simpler textual version of constraints, used on Search History page.
  # Theoretically can may be DRY'd up with results page render_constraints,
  # maybe even using the very same HTML with different CSS?
  # But too tricky for now, too many changes to existing CSS. TODO.
  def render_search_to_s(params, accessible_label = '')
    return render(Blacklight::ConstraintsComponent.for_search_history(search_state: convert_to_search_state(params))) unless overridden_search_history_constraints_helper_methods?

    Deprecation.warn(Blacklight::SearchHistoryConstraintsHelperBehavior, 'Calling out to potentially overridden helpers for backwards compatibility.')

    Deprecation.silence(Blacklight::SearchHistoryConstraintsHelperBehavior) do
      search = content_tag :dl, class: 'query row' do
        search_link = render_search_to_s_q(params) + render_search_to_s_filters(params)
        if search_link.blank?
          search_link = render_empty_search(params)
        end
        search_link
      end
      tag.span(accessible_label, class: 'sr-only') + search
    end
  end
  deprecation_deprecate render_search_to_s: 'Use Blacklight::ConstraintsComponent.for_search_history instead'

  def render_empty_search(params)
    render_search_to_s_element(nil, nil)
  end

  # value can be Array, in which case elements are joined with
  # 'and'.   Pass in option :escape_value => false to pass in pre-rendered
  # html for value. key with escape_key if needed.
  def render_search_to_s_element(key, value, _options = {})
    Deprecation.warn(Blacklight::SearchHistoryConstraintsHelperBehavior, '#render_search_to_s_element is deprecated without replacement')
    if value.blank?
      value = tag.span('blank', class: 'filter-value sr-only')
    end
    render_filter_name(key) + tag.dd(value, class: 'filter-values col-6 col-md-7 col-lg-8 mb-0')
  end

  # Render the name of the facet
  def render_filter_name name
    Deprecation.warn(Blacklight::SearchHistoryConstraintsHelperBehavior, '#render_filter_name is deprecated without replacement')
    tag.dt(t('blacklight.search.filters.label', label: name || 'Any Field'), class: 'filter-name col-6 col-md-5 col-lg-4')
  end

  ##
  # Render the value of the facet
  def render_filter_value value, key = nil
    Deprecation.warn(Blacklight::SearchHistoryConstraintsHelperBehavior, '#render_filter_value is deprecated without replacement')
    display_value = value
    Deprecation.silence(Blacklight::FacetsHelperBehavior) do
      display_value = facet_display_value(key, value) if key
    end
    if value.blank?
      return tag.span('blank', class: 'filter-value sr-only')
    end
    tag.span(h(display_value), class: 'filter-value')
  end
end
