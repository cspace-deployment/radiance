# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller

  include Blacklight::Catalog
  include BlacklightRangeLimit::ControllerOverride

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    config.index.thumbnail_presenter = ThumbnailPresenter
    config.view.gallery(document_component: Blacklight::Gallery::DocumentComponent)
    config.view.masonry(document_component: Blacklight::Gallery::DocumentComponent)
    config.view.slideshow(
      document_component: Blacklight::Gallery::SlideshowComponent,
      preview_component: Gallery::SlideshowPreviewComponent
    )
    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)

    # disable these three document action until we have resources to configure them to work
    config.show.document_actions.delete(:citation)
    config.show.document_actions.delete(:sms)
    config.show.document_actions.delete(:email)

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters

    # UCB customizations to support existing Solr cores
    config.default_solr_params = {
        'rows': 10,
        'facet.mincount': 1,
        'q.alt': '*:*',
        'defType': 'edismax',
        'df': 'text',
        'q.op': 'AND',
        'q.fl': '*,score'
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'
    config.document_solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    #config.index.display_type_field = 'format'
    config.index.thumbnail_field = 'blob_ss'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    # config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    # config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    # config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    #config.show.title_field = 'title_tsim'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # FACET FIELDS
    config.add_facet_field 'artistorigin_s', label: 'Country', limit: true
    config.add_facet_field 'artistcalc_s', label: 'Artist', limit: true
    config.add_facet_field 'itemclass_s', label: 'Classification', limit: true
    config.add_facet_field 'materials_s', label: 'Materials', limit: true
    # config.add_facet_field 'datemade_s', label: 'Date Made', limit: true
    config.add_facet_field("datemadeyear_i") do |field|
      field.include_in_advanced_search = false
      field.label = 'Date made'
      field.range = true
      field.index_range = true
    end
    # config.add_facet_field 'measurement_s', label: 'Dimensions', limit: true
    config.add_facet_field 'status_s', label: 'Status', limit: true
    config.add_facet_field('Has image') do |field|
      field.include_in_advanced_search = false
      field.query = {
        has_image: { label: 'Yes', fq: 'blob_ss:[* TO *]' },
        no_image: { label: 'No', fq: '-(blob_ss:[* TO *])' }
      }
    end

    # SEARCH FIELDS
    config.add_search_field 'idnumber_s', label: 'Accession Number'
    config.add_search_field 'itemclass_s', label: 'Classification'
    config.add_search_field 'artistcalc_s', label: 'Artist'
    config.add_search_field 'datemade_s', label: 'Date Made'
    config.add_search_field 'materials_s', label: 'Materials'
    config.add_search_field 'artistorigin_s', label: 'Country'
    config.add_search_field 'title_s', label: 'Title'
    config.add_search_field 'status_s', label: 'Status'
    config.add_search_field 'century_s', label: 'Century'

    # 'SHOW' VIEW FIELDS
    config.add_show_field 'artistcalc_s', label: 'Artist'
    config.add_show_field 'datemade_s', label: 'Date Made'
    config.add_show_field 'itemclass_s', label: 'Classification'
    config.add_show_field 'artistorigin_s', label: 'Country'
    config.add_show_field 'artistbirthdate_s', label: 'Artist birth Date'
    config.add_show_field 'artistdeathdate_s', label: 'Artist death Date'
    config.add_show_field 'datesactive_s', label: 'Dates Active'
    config.add_show_field 'measurement_s', label: 'Dimensions'
    config.add_show_field 'materials_s', label: 'Materials'
    config.add_show_field 'idnumber_s', label: 'Accession Number'
    config.add_show_field 'fullbampfacreditline_s', label: 'Full BAMPFA credit line'
    config.add_show_field 'copyrightcredit_s', label: 'Copyright credit'
    config.add_show_field 'century_s', label: 'Century'
    #config.add_show_field 'blob_ss', helper_method: 'render_media', label: 'Images'
    # gallery

    # 'INDEX' VIEW FIELDS
    config.add_index_field 'artistcalc_s', label: 'Artist'
    config.add_index_field 'itemclass_s', label: 'Classification'
    config.add_index_field 'materials_s', label: 'Materials'
    config.add_index_field 'measurement_s', label: 'Dimensions'
    config.add_index_field 'idnumber_s', label: 'Accession Number'
    # sort
    config.index.title_field = 'title_s'
    config.show.title_field = 'title_s'
    config.add_sort_field 'title_s asc', label: 'Title A-Z'
    config.add_sort_field 'title_s desc', label: 'Title Z-A'
    config.add_sort_field 'datemade_s asc', label: 'Date made ascending'
    config.add_sort_field 'datemade_s desc', label: 'Date made descending'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'text', label: 'All Fields'


    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the Solr field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case). Add the sort: option to configure a
    # custom Blacklight url parameter value separate from the Solr sort fields.
    config.add_sort_field 'relevance', sort: 'score desc, pub_date_si desc, title_si asc', label: 'relevance'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    # config.spell_max = 5

    # Configuration for autocomplete suggester
    config.autocomplete_enabled = false
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end
end
