# this is to allow nested layouts
# from https://mattbrictson.com/easier-nested-layouts-in-rails
# this is called for example from views/layouts/devise.html.erb
# allowing that layout to be inherited by the main blacklight layout

module LayoutsHelper
  def parent_layout(layout)
    @view_flow.set(:layout, output_buffer)
    output = render(:file => "layouts/#{layout}")
    self.output_buffer = ActionView::OutputBuffer.new(output)
  end
end
