module UrlHelper
  include Blacklight::UrlHelperBehavior

  # Search History and Saved Searches display
  def link_to_previous_search(params, index, count)
    Deprecation.silence(SearchHistoryConstraintsHelper) do
      link_to(
        render_search_to_s(params),
        search_action_path(params),
        class: 'd-block',
        aria: { description: "recent search #{index + 1} of #{count}" }
      )
    end
  end
end
