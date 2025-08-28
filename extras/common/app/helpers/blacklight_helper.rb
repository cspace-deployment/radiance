module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  ##
  # Render the document "heading" (title) in a content tag
  # @deprecated
  # @overload render_document_heading(document, options)
  #   @param [SolrDocument] document
  #   @param [Hash] options
  #   @option options [Symbol] :tag
  # @overload render_document_heading(options)
  #   @param [Hash] options
  #   @option options [Symbol] :tag
  # @return [String]
  def render_document_heading(*args)
    options = args.extract_options!
    document = args.first
    tag = options.fetch(:tag, :h4)
    document ||= @document

    content_tag(:div) do
      content_tag(:div, class: 'd-inline-block pr-4 w-md-75') do
        content_tag(tag, document_presenter(document).heading, itemprop: 'name')
      end + content_tag(:div, class: 'float-md-right w-md-25') do
        render('catalog/show_tools')
      end
    end
  end
  deprecation_deprecate render_document_heading: 'Removed without replacement'

end
