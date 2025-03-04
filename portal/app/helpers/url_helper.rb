module UrlHelper
  include Blacklight::UrlHelperBehavior

  # Search History and Saved Searches display
  def link_to_previous_search(params)
    Deprecation.silence(SearchHistoryConstraintsHelper) do
      link_to(render_search(params), search_action_path(params))
    end
  end
end
