# frozen_string_literal: true

module Blacklight
  class ConstraintLayoutComponent < Blacklight::Component
    def initialize(index:, value:, label: nil, remove_path: nil, classes: nil, search_state: nil)
      @index = index
      @value = value
      @label = label
      @remove_path = remove_path
      @classes = Array(classes).join(' ')
      @search_state = search_state
      @next_focus_target = focus_targets
    end

    def render?
      @value.present?
    end

    ##
    # Return a list of possible element IDs to receive focus after this constraint is removed.
    # The element IDs will be tried in order until an ID matching a visible element is found.
    #
    # @return [Array<String>]
    def focus_targets
      focus_targets = ["remove-constraint-#{@index}"]
      if @index > 0
        focus_targets << "remove-constraint-#{@index - 1}"
      end
      focus_targets << "facet-#{@label}-toggle-btn".parameterize
      focus_targets << 'facet-panel-collapse-toggle-btn'
      focus_targets
    end
  end
end
