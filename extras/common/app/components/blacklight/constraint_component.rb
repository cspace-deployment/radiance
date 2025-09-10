# frozen_string_literal: true

module Blacklight
  class ConstraintComponent < Blacklight::Component
    with_collection_parameter :facet_item_presenter

    def initialize(facet_item_presenter:, facet_item_presenter_counter:, index:, classes: 'filter', layout: Blacklight::ConstraintLayoutComponent)
      @facet_item_presenter = facet_item_presenter
      @index = index + facet_item_presenter_counter
      @classes = classes
      @layout = layout
    end
  end
end
