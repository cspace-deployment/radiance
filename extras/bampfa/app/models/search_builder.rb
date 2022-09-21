# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  include BlacklightRangeLimit::RangeLimitBuilder

  # @example Adding a new step to the processor chain
  self.default_processor_chain += [:add_random_sort]
  #
  def add_random_sort(solr_parameters)
		if search_state.params_for_search['sort']&. == 'random'
			require 'securerandom'
			random_string = SecureRandom.uuid
	    solr_parameters[:sort] = "random_%s asc" % random_string
		end
  end
end
