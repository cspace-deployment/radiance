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
    prefix  = 'Hearst Museum object'
    if document[:card_ss] && document[:card_ss].include?(thumbnail_value_from_document)
      prefix = 'Documentation associated with Hearst Museum object'
    end
    brief_description = unless document[:objdescr_txt].nil? then "described as #{document[:objdescr_txt][0]}" else 'no description available.' end
    if document[:restrictions_ss] && document[:restrictions_ss].include?('notpublic') && !document[:restrictions_ss].include?('public')
      brief_description += ' Notice: Image restricted due to its potentially sensitive nature. Contact Museum to request access.'
    end
    object_name = unless document[:objname_txt].nil? then "titled #{document[:objname_txt][0]}" else 'no title available' end
    object_number = unless document[:objmusno_txt].nil? then "accession number #{document[:objmusno_txt][0]}" else 'no object accession number available' end
    "#{prefix} #{object_name}, #{object_number}, #{brief_description}".html_safe
  end

  private

  delegate :thumbnail_field, :thumbnail_method, :default_thumbnail, to: :view_config

  # @param [Hash] image_options to pass to the image tag
  def thumbnail_value(image_options)
    value = if thumbnail_method
              view_context.send(thumbnail_method, document, image_options)
            elsif thumbnail_field
              image_options['alt'] = render_thumbnail_alt_text
              image_url = 'https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/' + thumbnail_value_from_document + '/derivatives/Medium/content'
              # image_options[:width] = '200px'
              view_context.image_tag image_url, image_options if image_url.present?
            end

    value || default_thumbnail_value(image_options)
  end

end
