module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  ##
  # Render the view type icon for the results view picker
  #
  # @deprecated
  # @param [String] view
  # @return [String]
  def render_view_type_group_icon view
    blacklight_icon(view, aria_hidden: true, label: false)
  end
  deprecation_deprecate render_view_type_group_icon: 'call blacklight_icon instead'
end
