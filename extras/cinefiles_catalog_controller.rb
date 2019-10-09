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


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    # no slideshow until thumbnail rendering is fixed
    #config.view.slideshow.partials = [:index]

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

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    #
    # UCB customizations to support existing Solr cores
    config.default_solr_params = {
      rows: 10,
      'facet.mincount': 1,
      'q.alt': '*:*',
      'defType': 'edismax',
      'df': 'text',
      'q.op': 'AND',
      'q.fl': '*,score'
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
    # UCB customization: this is needed for our Solr4 services
      q: '{!term f=id v=$id}'
    }

    # solr field configuration for search results/index views
    # UCB customization: list of blobs is hardcoded for both index and show displays
    #{index_title}
    config.index.thumbnail_field = 'blob_ss'

    # solr field configuration for document/show views
    #{show_title}
    config.show.thumbnail_field = 'blob_ss'

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


    #{facet}


    #{facet_dates}


    #config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #   :years_5 => { label: 'within 5 Years', fq: "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { label: 'within 10 Years', fq: "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { label: 'within 25 Years', fq: "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
    #}


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display

    #{index}

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display

    #{show}


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

    # UCB Customizations to use existing "catchall" field called text
    config.add_search_field 'text', label: 'Any Fields'
    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    #   config.add_search_field('text') do |field|
    #     # solr_parameters hash are sent to Solr as ordinary url query params.
    #     field.solr_parameters = { :'spellciheck.dictionary' => 'text' }
    #
    #     # :solr_local_parameters will be sent using Solr LocalParams
    #     # syntax, as eg {! qf=$title_qf }. This is neccesary to use
    #     # Solr parameter de-referencing like $title_qf.
    #     # See: http://wiki.apache.org/solr/LocalParams
    #     field.solr_local_parameters = {
    #       qf: '$text_qf',
    #       pf: '$text_pf'
    #     }
    #   end
    #
    #    config.add_search_field('author') do |field|
    #      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
    #      field.solr_local_parameters = {
    #        qf: '$author_qf',
    #        pf: '$author_pf'
    #      }
    #    end
    #
    #    # Specifying a :qt only to show it's possible, and so our internal automated
    #    # tests can test it. In this case it's the same as
    #    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    #    config.add_search_field('subject') do |field|
    #      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
    #      field.qt = 'search'
    #      field.solr_local_parameters = {
    #        qf: '$subject_qf',
    #        pf: '$subject_pf'
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).

    #{sort}

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'


    # sort
    config.add_sort_field 'doctitle_s asc', label: 'Doc title'
    config.add_sort_field 'filmtitle_s asc', label: 'Film title'
    config.index.title_field =  'doctitle_s'
    config.show.title_field =  'doctitle_s'

# NB: the following two ends are added by the ucb_bl.py script
#  end
#end


# facet
config.add_facet_field 'author_ss', label: 'Document author', limit: true
config.add_facet_field 'source_s', label: 'Document source', limit: true
config.add_facet_field 'doclanguage_ss', label: 'Document language', limit: true
config.add_facet_field 'code_s', label: 'Document code', limit: true
config.add_facet_field 'docsubject_ss', label: 'Document subject', limit: true

config.add_facet_field 'director_ss', label: 'Film director', limit: true
config.add_facet_field 'country_ss', label: 'Film country', limit: true
config.add_facet_field 'filmyear_s', label: 'Film year', limit: true
config.add_facet_field 'filmlanguage_s', label: 'Film language', limit: true
config.add_facet_field 'subject_ss', label: 'Film subject', limit: true
config.add_facet_field 'genre_ss', label: 'Film genre', limit: true

# index
config.add_index_field 'director_ss', label: 'Film director'
config.add_index_field 'country_ss', label: 'Film country'
config.add_index_field 'filmyear_s', label: 'Film year'
config.add_index_field 'filmlanguage_s', label: 'Film language'
config.add_index_field 'subject_ss', label: 'Film subject'
config.add_index_field 'genre_ss', label: 'Film genre'
# config.add_index_field 'doctitle_s', label: 'Document title'
config.add_index_field 'source_s', label: 'Document source'
config.add_index_field 'author_ss', label: 'Document author'
config.add_index_field 'doclanguage_ss', label: 'Document language'
config.add_index_field 'pubdate_s', label: 'Document date'

# search
config.add_search_field 'country_ss', label: 'Film country'
config.add_search_field 'director_ss', label: 'Film director'
config.add_search_field 'filmyear_s', label: 'Film year'
config.add_search_field 'filmlanguage_ss', label: 'Film language'
config.add_search_field 'subject_ss', label: 'Film subject'
config.add_search_field 'genre_ss', label: 'Film genre'
config.add_search_field 'doctitle_s', label: 'Document title'
config.add_search_field 'source_s', label: 'Document source'
config.add_search_field 'author_ss', label: 'Document author'
config.add_search_field 'doclanguage_s', label: 'Document language'
config.add_search_field 'pubdate_s', label: 'Document date'

# show
config.add_show_field 'id', label: 'ID'
config.add_show_field 'film_name_id_s', label: 'Film name id'
config.add_show_field 'doc_count_s', label: 'Film doc count'
config.add_show_field 'filmtitle_s', label: 'Film title'
config.add_show_field 'country_ss', label: 'Film country'
config.add_show_field 'filmyear_s', label: 'Film year'
config.add_show_field 'director_ss', label: 'Film director'
config.add_show_field 'filmlanguage_ss', label: 'Film language'
config.add_show_field 'prodco_ss', label: 'Film production company'
config.add_show_field 'subject_ss', label: 'Film subject'
config.add_show_field 'genre_ss', label: 'Film genre'
config.add_show_field 'title_s', label: 'Film title 2'
config.add_show_field 'prodco_id_s', label: 'Film production company ID'
config.add_show_field 'updatedat_s', label: 'Updated at'
# config.add_show_field 'doctitle_s', label: 'Document title'
config.add_show_field 'doctype_s', label: 'Document type'
config.add_show_field 'pages_s', label: 'Document pages'
config.add_show_field 'pg_info_s', label: 'Document pageinfo'
config.add_show_field 'source_s', label: 'Document source'
config.add_show_field 'src_id_s', label: 'Document source ID'
config.add_show_field 'author_ss', label: 'Document author'
config.add_show_field 'doc_name_id_s', label: 'Document name ID'
config.add_show_field 'doclanguage_s', label: 'Document language'
config.add_show_field 'pubdate_s', label: 'Document date'
config.add_show_field 'code_s', label: 'Document code'
config.add_show_field 'biblio_s', label: 'Has bibliography'
config.add_show_field 'bx_info_s', label: 'Has box info'
config.add_show_field 'cast_cr_s', label: 'Has cast credits'
config.add_show_field 'costinfo_s', label: 'Has cost info'
config.add_show_field 'dist_co_s', label: 'Has dstribution company'
config.add_show_field 'filmog_s', label: 'Has filmography'
config.add_show_field 'illust_s', label: 'Has illustrations'
config.add_show_field 'prod_co_ss', label: 'Has production co'
config.add_show_field 'tech_cr_s', label: 'Has tech credits'
config.add_show_field 'docurl_s', label: 'Document URL'
config.add_show_field 'pubdatescalar_s', label: 'Document publication date'
config.add_show_field 'latepubdatescalar_s', label: 'Document late pub date'
config.add_show_field 'srcurl_s', label: 'Document Source URL'
config.add_show_field 'docsubject_ss', label: 'Document subject'
config.add_show_field 'docnamesubject_s', label: 'Document name subject'
config.add_show_field 'blob_ss', helper_method: 'render_media', label: 'Images'
config.add_show_field 'card_ss', helper_method: 'render_media', label: 'Cards'


  end
end

