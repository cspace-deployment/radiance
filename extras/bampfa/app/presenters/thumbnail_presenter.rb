# frozen_string_literal: true

class ThumbnailPresenter < Blacklight::ThumbnailPresenter

  # @param [SolrDocument] document
  # @param [ActionView::Base] view_context scope for linking and generating urls
  #                                        as well as for invoking "thumbnail_method"
  # @param [Blacklight::Configuration::ViewConfig] view_config
  def initialize(document, view_context, view_config)
    @document = document
    @view_context = view_context
    @view_config = view_config
  end

  def render(image_options = {})
    thumbnail_value(image_options)
  end

  ##
  # Does the document have a thumbnail to render?
  #
  # @return [Boolean]
  def exists?
    thumbnail_method.present? ||
      (thumbnail_field && thumbnail_value_from_document.present?) ||
      default_thumbnail.present?
  end

  ##
  # Render the thumbnail, if available, for a document and
  # link it to the document record.
  #
  # @param [Hash] image_options to pass to the image tag
  # @param [Hash] url_options to pass to #link_to_document
  # @return [String]
  def thumbnail_tag image_options = {}, url_options = {}
    value = thumbnail_value(image_options)
    return value if value.nil? || url_options[:suppress_link]

    view_context.link_to_document document, value, url_options
  end

  def render_thumbnail_alt_text()
    prefix = document[:itemclass_s] || 'BAMPFA object'
    title = unless document[:title_s].nil? then "titled #{document[:title_s]}" else 'no title available' end
    materials = document[:materials_s] || 'of unknown materials'
    object_number = unless document[:idnumber_s].nil? then "accession number #{document[:idnumber_s]}" else 'no accession number available' end
    "#{prefix} #{title}, #{materials}, #{object_number}.".html_safe
  end

  private

  delegate :thumbnail_field, :thumbnail_method, :default_thumbnail, to: :view_config

  # @param [Hash] image_options to pass to the image tag
  def thumbnail_value(image_options)
    value = if thumbnail_method
              view_context.send(thumbnail_method, document, image_options)
            elsif thumbnail_field
              image_options['alt'] = render_thumbnail_alt_text
              image_url = 'https://webapps.cspace.berkeley.edu/bampfa/imageserver/blobs/' + thumbnail_value_from_document + '/derivatives/Medium/content'
              # image_options[:width] = '200px'
              view_context.image_tag image_url, image_options if image_url.present?
            end

    value || default_thumbnail_value(image_options)
  end

end
