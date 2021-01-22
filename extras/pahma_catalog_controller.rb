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

    # very custom PAHMA config ... not autogenerated!

    # sort
    config.add_sort_field 'objname_sort asc', label: 'Object name'
    config.add_sort_field 'objsortnum_s asc', label: 'Museum number'
    config.index.title_field =  'objname_s'
    config.show.title_field =  'objname_s'
    # index
    config.add_index_field 'deaccessioned_s', helper_method: 'render_status', label: 'Object status'
    config.add_index_field 'objmusno_s', label: 'Museum number'
    config.add_index_field 'objassoccult_ss', label: 'Culture or time period'
    config.add_index_field 'objmaker_ss', label: 'Maker or artist'
    config.add_index_field 'objfilecode_ss', label: 'Function'
    config.add_index_field 'objproddate_s', label: 'Production date'
    config.add_index_field 'objdimensions_ss', label: 'Dimensions'
    config.add_index_field 'objcollector_ss', label: 'Collector'
    config.add_index_field 'objfcp_s', label: 'Collection place'
    config.add_index_field 'objcolldate_s', label: 'Collection date'

    config.add_index_field 'taxon_ss', label: 'Taxon'
    config.add_index_field 'objpersondepicted_ss', label: 'Person depicted'
    config.add_index_field 'objplacedepicted_ss', label: 'Place depicted'
    config.add_index_field 'objculturedepicted_ss', label: 'Culture depicted'

    # search
    [
      ['objmusno_s_lower', 'Museum number'],
      ['objaltnum_ss', 'Alternate number'],
      ['objaccno_ss', 'Accession number'],
      ['objname_txt', 'Object name'],
      ['objdescr_txt', 'Description'],
      ['anonymousdonor_txt', 'Donor'],
      ['objfcp_txt', 'Collection place'],
      ['objpp_txt', 'Production place'],
      ['objassoccult_txt', 'Culture or time period'],
      ['objmaker_txt', 'Maker or artist'],
      ['objcollector_txt', 'Collector'],
      ['objcolldate_txt', 'Collection date'],
      ['objmaterials_txt', 'Materials'],

      ['taxon_txt', 'Taxon'],
      ['objpersondepicted_txt', 'Person depicted'],
      ['objplacedepicted_txt', 'Place depicted'],
      ['objculturedepicted_txt', 'Culture depicted'],

      ['objinscrtext_txt', 'Inscription'],
      ['objtype_txt', 'Object type'],
      ['objfilecode_txt', 'Function'],
      ['objcontextuse_txt', 'Context of use'],
      ['objkeelingser_txt', 'Keeling series'],
      ['objdept_txt', 'Department'],
      ['loan_info_txt', 'Loans']
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

    # keeping these here for now in case they are someday needed
    # config.add_search_field 'objmusno_s', label: 'Museum number'
    # config.add_search_field 'objaltnum_ss', label: 'Alternate number'
    # config.add_search_field 'objaccno_ss', label: 'Accession number'
    # config.add_search_field 'objname_s', label: 'Object name'
    # config.add_search_field 'objdescr_s', label: 'Description'
    # config.add_search_field 'anonymousdonor_ss', label: 'Donor'
    # config.add_search_field 'objfcp_s', label: 'Collection place'
    # config.add_search_field 'objpp_ss', label: 'Production place'
    # config.add_search_field 'objassoccult_ss', label: 'Culture or time period'
    # config.add_search_field 'objmaker_ss', label: 'Maker or artist'
    # config.add_search_field 'objmaterials_ss', label: 'Materials'
    ## config.add_search_field 'objpersondepicted_ss', label: 'Person depicted'
    ## config.add_search_field 'objplacedepicted_ss', label: 'Place depicted'
    ## config.add_search_field 'objculturedepicted_ss', label: 'Place depicted'
    ## config.add_search_field 'taxon_ss', label: 'Taxon'
    # config.add_search_field 'objinscrtext_ss', label: 'Inscription'
    # config.add_search_field 'objcollector_ss', label: 'Collector'
    # config.add_search_field 'objtype_s', label: 'Object type'
    # config.add_search_field 'objfilecode_ss', label: 'Function'
    # config.add_search_field 'objcontextuse_s', label: 'Context of use'
    ## config.add_search_field 'objproddate_s', label: 'Production date'
    ## config.add_search_field 'objacqdate_ss', label: 'Acquisition date'
    # config.add_search_field 'objcolldate_s', label: 'Collection date'
    ## config.add_search_field 'objaccdate_ss', label: 'Accession date'
    # config.add_search_field 'objkeelingser_s', label: 'Keeling series'

    # config.add_search_field 'objdept_s', label: 'Department'

    # restricted fields
    # has restrictions?
    # exibition number and title
    # storage location
    # storage container
    # group

    # show
    config.add_show_field 'deaccessioned_s', helper_method: 'render_status', label: 'Object status'
    config.add_show_field 'objmusno_s', label: 'Museum number'
    # the ark: we have to use the _txt version as we are already using the _s version above
    config.add_show_field 'objmusno_txt', helper_method: 'render_ark', label: 'Permalink'
    config.add_show_field 'objaltnum_ss', label: 'Alternate number'
    config.add_show_field 'objaccno_ss', label: 'Accession number'
    #config.add_show_field 'objname_s', label: 'Object name'
    config.add_show_field 'objcount_s', label: 'Object count'
    config.add_show_field 'objcountnote_s', label: 'Count note'
    config.add_show_field 'objdescr_s', label: 'Description'
    config.add_show_field 'anonymousdonor_ss', label: 'Donor'
    config.add_show_field 'objfcp_s', label: 'Collection place'
    config.add_show_field 'objfcpverbatim_s', label: 'Verbatim coll. place'
    # lat long
    #config.add_show_field 'objfcpelevation_s', label: 'Collection place elevation'
    config.add_show_field 'objpp_ss', label: 'Production place'
    config.add_show_field 'objassoccult_ss', label: 'Culture or time period'
    config.add_show_field 'objmaker_ss', label: 'Maker or artist'
    config.add_show_field 'objcollector_ss', label: 'Collector'
    config.add_show_field 'objcolldate_s', label: 'Collection date'
    config.add_show_field 'objmaterials_ss', label: 'Materials'

    config.add_show_field 'taxon_ss', label: 'Taxon'
    config.add_show_field 'objpersondepicted_ss', label: 'Person depicted', limit: true
    config.add_show_field 'objplacedepicted_ss', label: 'Place depicted', limit: true
    config.add_show_field 'objculturedepicted_ss', label: 'Culture depicted', limit: true

    config.add_show_field 'objinscrtext_ss', label: 'Inscription'
    config.add_show_field 'objtype_s', label: 'Object type'
    config.add_show_field 'objfilecode_ss', label: 'Function'

    config.add_show_field 'objproddate_s', label: 'Production date'
    config.add_show_field 'objaccdate_ss', label: 'Accession date'
    #config.add_show_field 'objacqdate_ss', label: 'Acquisition date'

    #config.add_show_field 'hasimages_s', label: 'Photographed'
    #config.add_show_field 'imagetype_ss', label: 'Image type'
    #config.add_show_field 'hascoords_s', label: 'Collection place mapped?'
    config.add_show_field 'objkeelingser_s', label: 'Keeling series number'

    # restricted fields
    # has restrictions?
    # exibition number and title
    # storage location
    # storage container
    # group

    config.add_show_field 'objcontextuse_s', label: 'Context of use'
    config.add_show_field 'objdept_s', label: 'Department'
    config.add_show_field 'objdimensions_ss', label: 'Dimensions'
    config.add_show_field 'objtitle_s', label: 'Title'
    config.add_show_field 'objcomment_s', label: 'Comment'
    config.add_show_field 'loan_info_ss', label: 'Loans'
    #config.add_show_field 'video_ss', helper_method: 'render_video_csid', label: 'Video'
    #config.add_show_field 'audio_ss', helper_method: 'render_audio_csid', label: 'Audio'
    config.add_show_field 'video_md5_ss', helper_method: 'render_video_directly', label: 'Video'
    config.add_show_field 'audio_md5_ss', helper_method: 'render_audio_directly', label: 'Audio'
    config.add_show_field 'blob_ss', helper_method: 'render_media', label: 'Images'
    config.add_show_field 'card_ss', helper_method: 'render_media', label: 'Legacy documentation'
    #config.add_show_field 'd3_csid_ss', helper_method: 'render_x3d_csid', label: '3D'
    config.add_show_field 'd3_md5_ss', helper_method: 'render_x3d_directly', label: '3D'

    # facets
    config.add_facet_field 'objname_s', label: 'Object name', limit: true, index_range: true
    config.add_facet_field 'objtype_s', label: 'Object type', limit: true, index_range: true
    config.add_facet_field 'media_available_ss', label: 'Media available'
    config.add_facet_field 'objfcptree_ss', label: 'Collection place', limit: true, index_range: true

    config.add_facet_field("objcolldate_begin_i") do |field|
      field.include_in_advanced_search = false
      field.label = 'Year collected'
      field.range = true
      field.index_range = true
    end
    # careful not to uncomment this one without deleting the definition above
    #config.add_facet_field 'objcolldate_begin_i', label: 'Year collected', range: true, index_range: true

    config.add_facet_field 'objcollector_ss', label: 'Collector', limit: true, index_range: true
    config.add_facet_field 'anonymousdonor_ss', label: 'Donor', limit: true, index_range: true
    config.add_facet_field 'objculturetree_ss', label: 'Culture or time period', limit: true, index_range: true
    config.add_facet_field 'objmaker_ss', label: 'Maker or artist', limit: true, index_range: true
    config.add_facet_field 'objmaterials_ss', label: 'Materials', limit: true, index_range: true

    config.add_facet_field 'taxon_ss', label: 'Taxon', limit: true, index_range: true
    config.add_facet_field 'objpersondepicted_ss', label: 'Person depicted', limit: true, index_range: true
    config.add_facet_field 'objplacedepicted_ss', label: 'Place depicted', limit: true, index_range: true
    config.add_facet_field 'objculturedepicted_ss', label: 'Culture depicted', limit: true, index_range: true

    #config.add_facet_field 'hasimages_s', label: 'Photographed'
    #config.add_facet_field 'imagetype_ss', label: 'Image type'
    #config.add_facet_field 'hascoords_s', label: 'Collection place mapped?'

    # subject to further review (and in some cases, implementation)
    config.add_facet_field 'objaccno_ss', label: 'Accession number', limit: true, index_range: true
    config.add_facet_field 'objpp_ss', label: 'Production place', limit: true, index_range: true
    ##config.add_facet_field 'objproddate_begin_i', label: 'Production year', range: true, index_range: true

    config.add_facet_field("objaccdate_begin_is") do |field|
      field.include_in_advanced_search = false
      field.label = 'Accession year'
      field.range = true
      field.index_range = true
    end
    # careful not to uncomment this one without deleting the definition above
    ##config.add_facet_field 'objaccdate_begin_is', label: 'Accession year', range: true, index_range: true

    ##config.add_facet_field 'objacqdate_ss', label: 'Acquisition date', limit: true, index_range: true
    ##config.add_facet_field 'objacqdate_begin_is', label: 'Acquisition year', range: true, index_range: true
    config.add_facet_field 'objfilecode_ss', label: 'Function', limit: true
    config.add_facet_field 'loan_info_ss', label: 'Loans', limit: true
    #config.add_facet_field 'objkeelingser_s', label: 'Keeling series', limit: true, index_range: true
    #config.add_facet_field 'objdept_s', label: 'Department', limit: true

    # gallery
  end

  def decode_ark
    # decode ARK ID, e.g. hm21114461@2E1 -> 11-4461.1, hm210k3711a@2Df -> K-3711a-f
    museum_number = CGI.unescape(params[:ark].gsub('@','%')).sub('hm2','')
    museum_number = if museum_number[0] == 'x'
        museum_number[1..-1]
    else
        left, right = museum_number[1..2], museum_number[3..-1]
        left = left.gsub(/^0+/, '')
        right = right.gsub(/^0+/, '')
        left + '-' + right
    end

    redirect_to  :controller => 'catalog', action: 'index', search_field: 'objmusno_s_lower', q: '"' + museum_number + '"'
    #redirect_to  :controller => 'catalog', action: 'show', id: csid

  end

end
