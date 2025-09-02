module UrlHelper
  include Blacklight::UrlHelperBehavior

  # Adds a query parameter containing a message to be provided to screen readers
  # after navigating to the href.
  def with_screen_reader_alert(href, msg, focus_target = nil)
    sr_alert = ERB::Util.url_encode(msg)
    uri = URI.parse(href)
    parsed_query = Rack::Utils.parse_query(uri.query)
    uri.query = parsed_query.merge(sr_alert: sr_alert).to_query
    uri.to_s
  end

  # Search History and Saved Searches display
  def link_to_previous_search(params, index, count)
    Deprecation.silence(SearchHistoryConstraintsHelper) do
      link_to(
        render_search_to_s(params),
        search_action_path(params),
        class: 'd-block'
      )
    end
  end

  # Uses the catalog_path route to create a link to the show page for an item.
  # catalog_path accepts a hash. The solr query params are stored in the session,
  # so we only need the +counter+ param here. We also need to know if we are viewing to document as part of search results.
  # TODO: move this to the IndexPresenter
  # @param doc [SolrDocument] the document
  # @param field_or_opts [Hash, String] either a string to render as the link text or options
  # @param opts [Hash] the options to create the link with
  # @option opts [Number] :counter (nil) the count to set in the session (for paging through a query result)
  # @example Passing in an image
  #   link_to_document(doc, '<img src="thumbnail.png">', counter: 3) #=> "<a href=\"catalog/123\" data-tracker-href=\"/catalog/123/track?counter=3&search_id=999\"><img src="thumbnail.png"></a>
  # @example With the default document link field
  #   link_to_document(doc, counter: 3) #=> "<a href=\"catalog/123\" data-tracker-href=\"/catalog/123/track?counter=3&search_id=999\">My Title</a>
  def link_to_document(doc, field_or_opts = nil, opts = { counter: nil })
    label = case field_or_opts
            when NilClass
              document_presenter(doc).heading
            when Hash
              opts = field_or_opts
              document_presenter(doc).heading
            when Proc, Symbol
              Deprecation.warn(self, "passing a #{field_or_opts.class} to link_to_document is deprecated and will be removed in Blacklight 8")
              Deprecation.silence(Blacklight::IndexPresenter) do
                index_presenter(doc).label field_or_opts, opts
              end
            else # String
              field_or_opts
            end
    description = ''
    if 'document' == doc['common_doctype_s'] then
      date = unless doc['pubdate_s'].blank? then " published #{doc['pubdate_s']}" else '' end
      source = unless doc['source_s'].blank? then " in #{doc['source_s']}" else '' end
      author = unless doc['author_ss'].blank? then " by #{doc['author_ss'][0]}" else '' end
      description = ", #{doc['doctype_s']}#{date}#{source}#{author}"
    else
      year = unless doc['film_year_i'].blank? then " (#{doc['film_year_i']})" else '' end
      director = unless doc['film_director_ss'].blank? then ", directed by #{doc['film_director_ss'][0]}" else ', film' end
      description = "#{year}#{director}"
    end

    Deprecation.silence(Blacklight::UrlHelperBehavior) do
      link_to(
        label,
        url_for_document(doc),
        {
          **document_link_params(doc, opts),
          aria: {label: "#{label}#{description}".html_safe}
        }
      )
    end
  end
end
