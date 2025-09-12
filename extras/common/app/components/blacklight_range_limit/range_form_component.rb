# frozen_string_literal: true

module BlacklightRangeLimit
  class RangeFormComponent < Blacklight::Component
    delegate :search_action_path, to: :helpers

    def initialize(facet_field:, classes: BlacklightRangeLimit.classes)
      @facet_field = facet_field
      @classes = classes
    end

    def begin_label
      range_config[:input_label_range_begin] || t("blacklight.range_limit.range_begin", field_label: @facet_field.label)
    end

    def end_label
      range_config[:input_label_range_end] || t("blacklight.range_limit.range_end", field_label: @facet_field.label)
    end

    def maxlength
      range_config[:maxlength]
    end

    # type is 'begin' or 'end'
    def render_range_input(type, input_label = nil, maxlength_override = nil)
      type = type.to_s

      default = if @facet_field.selected_range.is_a?(Range)
                  case type
                  when 'begin' then @facet_field.selected_range.first
                  when 'end' then @facet_field.selected_range.last
                  end
                end
      element_name = "range[#{@facet_field.key}][#{type}]"
      element_id = if @facet_field.in_modal?
                     "range-#{@facet_field.key}-#{type}-modal"
                   else
                     "range-#{@facet_field.key}-#{type}"
                   end
      html = number_field_tag(
        element_name,
        default,
        id: element_id,
        maxlength: maxlength_override || maxlength,
        class: "form-control text-center range_#{type}"
      )
      html += label_tag(
        element_id,
        input_label,
        class: 'sr-only visually-hidden',
        'for': element_id
      ) if input_label.present?
      html
    end

    private

    ##
    # the form needs to serialize any search parameters, including other potential range filters,
    # as hidden fields. The parameters for this component's range filter are serialized as number
    # inputs, and should not be in the hidden params.
    # @return [Blacklight::HiddenSearchStateComponent]
    def hidden_search_state
      hidden_search_params = @facet_field.search_state.params_for_search.except(:utf8, :page)
      hidden_search_params[:sr_alert] = "Added \"#{@facet_field.label}\" range to search constraints"
      hidden_search_params[:focus_target] = "#remove-facet-#{@facet_field.label.parameterize}-range"
      hidden_search_params[:range]&.except!(@facet_field.key)
      Blacklight::HiddenSearchStateComponent.new(params: hidden_search_params)
    end

    def range_config
      @facet_field.range_config
    end
  end
end
