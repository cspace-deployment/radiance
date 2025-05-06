# frozen_string_literal: true

class SearchBarComponent < Blacklight::SearchBarComponent

  def initialize(
    url:,
    params:,
    advanced_search_url: nil,
    presenter: nil,
    classes: ['search-query-form'],
    prefix: nil,
    method: 'GET',
    q: nil,
    query_param: :q,
    search_field: nil,
    search_fields: nil,
    autocomplete_path: nil,
    autofocus: nil,
    i18n: { scope: 'blacklight.search.form' },
    form_options: {}
  )
    return super(url: url, params: params, prefix: 'search-bar-')
  end
end
