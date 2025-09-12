# frozen_string_literal: true

module RenderConstraintsHelper
  include Blacklight::RenderConstraintsHelperBehavior
  include BlacklightAdvancedSearch::RenderConstraintsOverride

  # Overrides BlacklightAdvancedSearch::RenderConstraintsOverride.query_has_constraints? to return
  # true when the query has range limit constraints.
  def query_has_constraints?(localized_params = params)
    if is_advanced_search? localized_params
      true
    else
      !(localized_params[:q].blank? &&
        localized_params[:f].blank? &&
        localized_params[:f_inclusive].blank?
        localized_params[:range].blank?
      )
    end
  end

  ##
  # Render the actual constraints, not including header or footer
  # info.
  #
  # @param [Hash] localized_params query parameters
  # @return [String]
  def render_constraints(localized_params = params, local_search_state = search_state)
    params_or_search_state = if localized_params != params
                               localized_params
                             else
                               local_search_state
                             end
    index = 0
    Deprecation.silence(Blacklight::RenderConstraintsHelperBehavior) do
      query_element = render_constraints_query(index, params_or_search_state)
      if query_element.present?
        index += 1
      end
      clause_elements = render_constraints_clauses(index, params_or_search_state)
      if clause_elements.present?
        index += search_state.clause_params.length
      end
      filter_elements = render_constraints_filters(index, params_or_search_state)
      query_element + clause_elements + filter_elements
    end
  end

  ##
  # Render the query constraints
  #
  # @deprecated
  # @param [Integer] index position of this constraint in the list of active constraints.
  # @param [Blacklight::SearchState,ActionController::Parameters] params_or_search_state query parameters
  # @return [String]
  def render_constraints_query(index, params_or_search_state = search_state)
    if (advanced_query.nil? || advanced_query.keyword_queries.empty?)
      Deprecation.warn(Blacklight::RenderConstraintsHelperBehavior, 'render_constraints_query is deprecated')
      search_state = convert_to_search_state(params_or_search_state)

      # So simple don't need a view template, we can just do it here.
      return "".html_safe if search_state.query_param.blank?

      Deprecation.silence(Blacklight::RenderConstraintsHelperBehavior) do
        render_constraint_element(
          constraint_query_label(search_state.params),
          search_state.query_param,
          index: index,
          classes: ["query"],
          remove: remove_constraint_url(search_state)
        )
      end
    else
      render_advanced_constraints_query(index, params_or_search_state)
    end
  end

  ##
  # Render the clause constraints
  #
  # @deprecated
  # @param [Integer] index starting position of the clause constraints in the list of active constraints.
  # @param [Blacklight::SearchState,ActionController::Parameters] params_or_search_state query parameters
  # @return [String]
  def render_constraints_clauses(index, params_or_search_state = search_state)
    search_state = convert_to_search_state(params_or_search_state)

    clause_presenters = search_state.clause_params.map do |key, clause|
      field_config = blacklight_config.search_fields[clause[:field]]
      Blacklight::ClausePresenter.new(key, clause, field_config, self, search_state)
    end

    render(Blacklight::ConstraintComponent.with_collection(clause_presenters, index: index))
  end
  deprecation_deprecate :render_constraints_clauses

  ##
  # Render the facet constraints
  # @deprecated
  # @param [Integer] index starting position of this facet field's constraints in the list of active constraints.
  # @param [Blacklight::SearchState,Hash] params_or_search_state query parameters
  # @return [String]
  def render_constraints_filters(index, params_or_search_state = search_state)
    Deprecation.warn(Blacklight::RenderConstraintsHelperBehavior, 'render_constraints_filters is deprecated')
    search_state = convert_to_search_state(params_or_search_state)

    content = "".html_safe

    if search_state.filters.any?
      Deprecation.silence(Blacklight::RenderConstraintsHelperBehavior) do
        content << safe_join(search_state.filters.map do |field|
          filter_element = render_filter_element(field.key, field.values, search_state, index)
          index += field.values.length
          filter_element
        end, "\n")
      end
    end
    if advanced_query
      content << render_advanced_constraints_filters(index, params_or_search_state)
      index += advanced_query.filters.length
    end
    content
  end

  ##
  # Render a single facet's constraint
  # @deprecated
  # @param [String] facet field
  # @param [Array<String>] values selected facet values
  # @param [Blacklight::SearchState] search_state path query parameters
  # @param [Integer] index position of this constraint in the list of active constraints.
  # @return [String]
  def render_filter_element(facet, values, search_state, index)
    Deprecation.warn(Blacklight::RenderConstraintsHelperBehavior, 'render_filter_element is deprecated')
    facet_config = facet_configuration_for_field(facet)

    safe_join(Array(values).map do |val|
      next if val.blank? # skip empty string

      Deprecation.silence(Blacklight::RenderConstraintsHelperBehavior) do
        presenter = if val.is_a? Array
                      inclusive_facet_item_presenter(facet_config, val, facet)
                    else
                      facet_item_presenter(facet_config, val, facet)
                    end

        filter_element = render_constraint_element(
          presenter.field_label,
          presenter.label,
          index: index,
          remove: presenter.remove_href(search_state),
          classes: ["filter", "filter-" + facet.parameterize]
        )
        index += 1
        filter_element
      end
    end, "\n")
  end

  # Render a label/value constraint on the screen. Can be called
  # by plugins and such to get application-defined rendering.
  #
  # Can be over-ridden locally to render differently if desired,
  # although in most cases you can just change CSS instead.
  #
  # Can pass in nil label if desired.
  #
  # @deprecated
  # @param [String] label to display
  # @param [String] value to display
  # @param [Hash] options
  # @option options [Integer] :index position of this constraint in the list of active constraints.
  # @option options [String] :remove url to execute for a 'remove' action
  # @option options [Array<String>] :classes an array of classes to add to container span for constraint.
  # @return [String]
  def render_constraint_element(label, value, options = {})
    Deprecation.warn(Blacklight::RenderConstraintsHelperBehavior, 'render_constraints_element is deprecated')
    render(partial: "catalog/constraints_element", locals: { label: label, value: value, options: options })
  end

  private

  # Overrides BlacklightAdvancedSearch::RenderConstraintsOverride.render_constraints_query to add index.
  def render_advanced_constraints_query(index, my_params = params)
    content = []
    advanced_query.keyword_queries.each_pair do |field, query|
      label = blacklight_config.search_fields[field][:label]
      content << render_constraint_element(
        label,
        query,
        index: index,
        :remove =>
          search_action_path(remove_advanced_keyword_query(field, my_params).except(:controller, :action))
      )
      index += 1
    end
    if (advanced_query.keyword_op == "OR" &&
        advanced_query.keyword_queries.length > 1)
      content.unshift content_tag(:span, "Any of:", class: 'operator')
      content_tag :span, class: "inclusive_or appliedFilter well" do
        safe_join(content.flatten, "\n")
      end
    else
      safe_join(content.flatten, "\n")
    end
  end

  # Overrides BlacklightAdvancedSearch::RenderConstraintsOverride.render_constraints_filters to add index.
  def render_advanced_constraints_filters(index, my_params = params)
    content = ''
    advanced_query.filters.each_pair do |field, value_list|
      label = facet_field_label(field)
      +content << render_constraint_element(
        label,
        safe_join(Array(value_list), " <strong class='text-muted constraint-connector'>OR</strong> ".html_safe),
        index: index,
        :remove => search_action_path(remove_advanced_filter_group(field, my_params).except(:controller, :action))
      )
      index += 1
    end
    content
  end
end
