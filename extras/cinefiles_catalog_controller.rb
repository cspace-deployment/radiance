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
    config.advanced_search[:query_parser] ||= 'edismax'
    config.advanced_search[:form_solr_parameters] ||= {}


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.view.gallery.partials = [:index_header, :index]
    # disable 'masonry' view
    # config.view.masonry.partials = [:index]
    # no slideshow until thumbnail rendering is fixed
    # config.view.slideshow.partials = [:index]

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
    config.show.catalogcard_field = 'card_ss'

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
    config.add_search_field 'text', label: 'Any field'
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

    #
    # FACETS
    #
    
    # Document record fields
    config.add_facet_field 'doctype_s', label: 'Document: type', limit: true
    config.add_facet_field 'doclanguage_ss', label: 'Document: language', limit: true
    # config.add_facet_field 'pubdatescalar_s', label: 'Document: publication date', limit: true
    config.add_facet_field("pubdate_i") do |field|
      field.include_in_advanced_search = false
      field.label = 'Document: publication year'
      field.range = true
      field.index_range = true
    end
    config.add_facet_field 'author_ss', label: 'Document: author', limit: true
    config.add_facet_field 'director_ss', label: 'Document: director as subject', limit: true
    config.add_facet_field 'filmtitle_ss', label: 'Document: film title', limit: true
    # config.add_facet_field 'has_ss', label: 'Document: content details', limit: true
    config.add_facet_field 'country_ss', label: 'Document: film country of production', limit: true
    config.add_facet_field 'filmyear_ss', label: 'Document: film production year', limit: true
    config.add_facet_field 'filmlanguage_ss', label: 'Document: film language', limit: true
    # config.add_facet_field 'genre_ss', label: 'Document: film genre', limit: true

    # Film record fields
    config.add_facet_field 'film_title_ss', label: 'Film title', limit: true
    config.add_facet_field 'film_director_ss', label: 'Film director', limit: true
    # config.add_facet_field 'film_year_ss', label: 'Film year', limit: true
    config.add_facet_field("film_year_i") do |field|
      field.include_in_advanced_search = false
      field.label = 'Film release year'
      field.range = true
      field.index_range = true
    end
    config.add_facet_field 'film_country_ss', label: 'Film country', limit: true
    config.add_facet_field 'film_language_ss', label: 'Film language', limit: true
    # config.add_facet_field 'film_prodco_ss', label: 'Film production company', limit: true
    # config.add_facet_field 'film_subject_ss', label: 'Film subject(s)', limit: true
    config.add_facet_field 'film_genre_ss', label: 'Film genre', limit: true

    # only for testing... allows one to see the value of access code in the ui
    # config.add_facet_field 'code_s', label: 'Access code', limit: true

    # Common fields
    config.add_facet_field 'common_doctype_s', label: 'Record type', limit: true

    #
    # SEARCH DROPDOWN & ADVANCED SEARCH
    #

    [
        ['doctype_txt', 'Document: type'],
        ['source_txt', 'Document: source'],
        ['author_txt', 'Document: author'],
        ['doclanguage_txt', 'Document: language'],
        ['pubdate_txt', 'Document: publication year'],
        # ['biblio_txt', 'Has bibliography'],
        # ['bx_info_txt', 'Has box info'],
        # ['cast_cr_txt', 'Has cast credits'],
        # ['costinfo_txt', 'Has cost info'],
        # ['dist_co_txt', 'Has distribution company'],
        # ['filmog_txt', 'Has filmography'],
        # ['illust_txt', 'Has illustrations'],
        # ['prod_co_txt', 'Has production co'],
        # ['tech_cr_txt', 'Has tech credits'],
        ['director_txt', 'Document: director as subject'],
        ['title_txt', 'Document: film title'],
        # ['filmtitle_txt', 'Associated films'],
        ['country_txt', 'Document: film country'],
        ['filmyear_txt', 'Document: film year'],
        ['filmlanguage_txt', 'Document: film language'],
        ['docnamesubject_txt', 'Document: name subject'],
        # ['prodco_txt', 'Film production company']
        # ['genre_txt', 'Film genre(s)'],
        # the following field needs to stay 'active' for the film/document linking to work properly
        ['film_id_ss', 'Film ID']

    ].each do |search_field|
      config.add_search_field(search_field[0]) do |field|
        field.label = search_field[1]
        #field.solr_parameters = { :'spellcheck.dictionary' => search_field[0] }
        field.solr_parameters = {
            qf: search_field[0],
            pf: search_field[0]
        }
      end
    end

    # 
    # "SHOW" DISPLAY FIELD
    #

    # DOCUMENT RECORDS
    config.add_show_field 'author_ss', label: 'Document author(s)'
    config.add_show_field 'source_s', label: 'Document source'
    # config.add_show_field 'srcurl_s', label: 'Document Source URL'
    config.add_show_field 'pubdate_s', label: 'Publication date'
    config.add_show_field 'doclanguage_ss', label: 'Document language'
    config.add_show_field 'doctype_s', label: 'Document type'
    config.add_show_field 'pages_s', label: 'Number of pages' 
    config.add_show_field 'pg_info_s', label: 'Source pagination' 
    config.add_show_field 'docnamesubject_ss', label: 'Document name subject'

    config.add_show_field 'has_ss', label: 'Document contains'
    config.add_show_field 'film_info_ss', helper_method: 'render_film_links', label: 'Related films'
    # config.add_show_field 'biblio_s', label: 'Has bibliography'
    # config.add_show_field 'bx_info_s', label: 'Has box info'
    # config.add_show_field 'cast_cr_s', label: 'Has cast credits'
    # config.add_show_field 'costinfo_s', label: 'Has cost info'
    # config.add_show_field 'dist_co_s', label: 'Has distribution company'
    # config.add_show_field 'filmog_s', label: 'Has filmography'
    # config.add_show_field 'illust_s', label: 'Has illustrations'
    # config.add_show_field 'prod_co_s', label: 'Has production co'
    # config.add_show_field 'tech_cr_s', label: 'Has tech credits'
    # config.add_show_field 'title_ss', label: 'Film title variations'
    # config.add_show_field 'director_ss', label: 'Film director'

    config.add_show_field 'filmyear_s', label: 'Film release year'
    config.add_show_field 'country_ss', label: 'Film country(ies)'
    config.add_show_field 'filmlanguage_ss', label: 'Film language(s)'
    config.add_show_field 'prodco_ss', label: 'Film production company'
    config.add_show_field 'genre_ss', label: 'Film genre(s)'

    config.add_show_field 'subject_ss', helper_method: 'render_multiline', label: 'Film subject(s)'
    config.add_show_field 'blob_ss', helper_method: 'render_linkless_media', label: 'Images'
    # config.add_show_field 'blob_ss', helper_method: 'render_restricted_media', label: 'Images'
    # config.add_show_field 'card_ss', helper_method: 'render_media', label: 'Cards'
    config.add_show_field 'pdf_ss', helper_method: 'check_and_render_pdf', label: 'PDFs'
    # config.add_show_field 'code_s', label: 'Access code'

    # FILM RECORDS
    # config.add_show_field 'film_title_ss', label: 'Film title'
    config.add_show_field 'film_title_variations_ss', label: 'Title variations'
    config.add_show_field 'film_director_ss', label: 'Director'
    config.add_show_field 'film_country_ss', label: 'Country(ies)'
    config.add_show_field 'film_year_ss', label: 'Release year'
    config.add_show_field 'film_language_ss', label: 'Language(s)'
    config.add_show_field 'film_prodco_ss', label: 'Production company(ies)'
    config.add_show_field 'film_genre_ss', label: 'Genre(s)'
    config.add_show_field 'film_subject_ss', helper_method: 'render_multiline', label: 'Subject(s)'
    config.add_show_field 'film_doc_count_ss', label: 'Related documents'
    config.add_show_field 'film_link_ss', helper_method: 'render_doc_link', label: 'View documents'
    # only for testing... allows one to see the value of access code in the ui
    # config.add_show_field 'code_s', label: 'Access code'

    # gallery
    
    #
    # "INDEX" DISPLAY FIELDS 
    #

    # Document records
    config.add_index_field 'common_doctype_s', label: 'Record type'
    config.add_index_field 'doctype_s', label: 'Document type'
    config.add_index_field 'author_ss', label: 'Document author(s)'
    config.add_index_field 'pubdate_s', label: 'Publication date'
    config.add_index_field 'source_s', label: 'Document source'
    # config.add_index_field 'doclanguage_ss', label: 'Document language'

    config.add_index_field 'has_ss', label: 'Document contains'
    config.add_index_field 'pages_s', label: 'Number of pages'
    # config.add_index_field 'pg_info_s', label: 'Source pagination'
    config.add_index_field 'film_info_ss', helper_method: 'render_film_links', label: 'Related films'

    # Film records
    config.add_index_field 'film_director_ss', label: 'Film director'
    config.add_index_field 'film_country_ss', label: 'Country(ies)'
    # config.add_index_field 'filmyear_s', label: 'Release year'
    # config.add_index_field 'film_title_ss', label: 'Film title'. 
    config.add_index_field 'film_language_ss', label: 'Language'
    config.add_index_field 'film_year_ss', label: 'Release year'
    config.add_index_field 'film_link_ss', helper_method: 'render_doc_link', label: 'Related documents'
    
    # sort
    config.index.title_field = 'common_title_ss'
    config.show.title_field = 'common_title_ss'
    # config.add_sort_field 'doctitle_ss asc', label: 'document title'
    # config.add_sort_field 'film_info_ss asc', label: 'first film title'
    config.add_sort_field 'common_title_ss asc', label: 'Title A-Z'
    config.add_sort_field 'common_title_ss desc', label: 'Title Z-A'
    config.add_sort_field 'pubdate_s asc', label: 'Document publication date'
    config.add_sort_field 'film_year_ss asc', label: 'Film release date'

  end

  def decode_ark
    # decode ARK ID, e.g. hm21114461@2E1 -> 11-4461.1, hm210k3711a@2Df -> K-3711a-f
    museum_number = CGI.unescape(params[:ark].gsub('@', '%')).sub('hm2', '')
    museum_number = if museum_number[0] == 'x'
      museum_number[1..-1]
    else
      left, right = museum_number[1..2], museum_number[3..-1]
      left = left.gsub(/^0+/, '')
      right = right.gsub(/^0+/, '')
      left + '-' + right
    end

    redirect_to :controller => 'catalog', action: 'index', search_field: 'objmusno_s_lower', q: '"' + museum_number + '"'
    #redirect_to  :controller => 'catalog', action: 'show', id: csid
  end

end
