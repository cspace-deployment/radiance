# frozen_string_literal: true

require 'rails_helper'

describe RenderConstraintsHelper, type: :helper do
  around { |test| Deprecation.silence(Blacklight::RenderConstraintsHelperBehavior) { test.call } }

  let(:config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'type'
      config.add_search_field 'title'
    end
  end

  let(:advanced_query) do
    BlacklightAdvancedSearch::QueryParser.new(params, config)
  end

  before do
    # the helper methods below infer paths from the current route
    controller.request.path_parameters[:controller] = 'catalog'

    allow(helper).to receive(:blacklight_config).and_return(config)
    allow(helper).to receive(:advanced_query).and_return(advanced_query)
    allow(controller).to receive(:respond_to?).with(:search_state_class).and_return(true)
    allow(controller).to receive(:respond_to?).with(:search_state_class, true).and_return(true)
    allow(controller).to receive(:search_state_class).and_return(Blacklight::SearchState)
    allow(controller).to receive(:respond_to?).with(:_routes)
    allow(controller).to receive(:respond_to?).with(:url_options).and_return(true)
    allow(controller).to receive(:respond_to?).with(:url_options, true).and_return(true)
    allow(controller).to receive(:url_options).and_return({:action => 'catalog'})
  end

  describe '#render_constraints_query' do
    subject { helper.render_constraints_query(index, params) }

    before do
      allow(helper).to receive(:url_for).with({:action=>"catalog", :f=>{"type"=>["journal"]}}).and_return('/catalog?f%5Btype%5D%5B%5D=journal')
    end

    let(:index) { 1 }
    let(:my_engine) { double("Engine") }
    let(:params) { ActionController::Parameters.new(q: 'foobar', f: { type: 'journal' }) }
    let(:expected_sr_alert) { 'sr_alert=Removed%2520%253A%2520%2522foobar%2522%2520from%2520search%2520constraints' }
    let(:expected_focus_targets) { 'focus_target=%255B%2522%2523remove-constraint-1%2522%252C%2520%2522%2523remove-constraint-0%2522%252C%2520%2522%2523facets%2520.facet-limit%253Afirst-child%2520button%2522%252C%2520%2522%2523facet-panel-collapse-toggle-btn%2522%255D' }

    it "overrides default 'remove constraint' link by adding sr_alert and focus_target parameters to the query string" do
      expect(subject).to have_link(
        'Remove constraint',
        href: "/catalog?f%5Btype%5D%5B%5D=journal&#{expected_sr_alert}&#{expected_focus_targets}",
        id: "remove-constraint-#{index}"
      )
    end
  end

  describe '#render_constraints_clauses' do
    subject { helper.render_constraints_clauses(index, params) }

    before do
      allow(helper).to receive(:url_for).with({"action"=>"catalog", "clause"=>{}, "f"=>{"type"=>["journal"]}}).and_return('/catalog?f%5Btype%5D%5B%5D=journal')
    end

    let(:index) { 0 }
    let(:my_engine) { double("Engine") }
    let(:params) { ActionController::Parameters.new(clause: { "0": { field: 'title', query: 'nature' } }, f: { type: 'journal' }) }
    let(:expected_sr_alert) { 'sr_alert=Removed%2520Title%253A%2520%2522nature%2522%2520from%2520search%2520constraints' }
    let(:expected_focus_targets) { 'focus_target=%255B%2522%2523remove-constraint-1%2522%252C%2520%2522%2523remove-constraint-0%2522%252C%2520%2522%2523facets%2520.facet-limit%253Afirst-child%2520button%2522%252C%2520%2522%2523facet-panel-collapse-toggle-btn%2522%255D' }

    it 'renders the clause constraint' do
      expect(subject).to have_selector '.constraint-value', text: /Title\s+nature/
    end

    it "has a link relative to the current url" do
      expect(subject).to have_link(
        'Remove constraint Title: nature',
        href: "/catalog?f%5Btype%5D%5B%5D=journal&#{expected_sr_alert}&#{expected_focus_targets}",
        id: "remove-constraint-#{index + 1}"
      )
    end
  end

  describe '#render_filter_element' do
    subject { helper.render_filter_element('type', ['journal'], path, index) }

    before do
      allow(helper).to receive(:blacklight_config).and_return(config)
      expect(helper).to receive(:facet_field_label).with('type').and_return("Item Type")
      allow(helper).to receive(:url_for).with({"action"=>"catalog", "q"=>"biz"}).and_return('/catalog?q=biz')
    end

    let(:index) { 0 }
    let(:params) { ActionController::Parameters.new q: 'biz' }
    let(:path) { Blacklight::SearchState.new(params, config, controller) }
    let(:expected_sr_alert) { 'sr_alert=Removed%2520Item%2520Type%253A%2520%2522journal%2522%2520from%2520search%2520constraints' }
    let(:expected_focus_targets) { 'focus_target=%255B%2522%2523remove-constraint-0%2522%252C%2520%2522%2523facets%2520.facet-limit%253Afirst-child%2520button%2522%252C%2520%2522%2523facet-panel-collapse-toggle-btn%2522%255D' }

    it "overrides default 'remove constraint' link by adding sr_alert and focus_target parameters to the query string" do
      expect(subject).to have_link(
        "Remove constraint Item Type: journal",
        href: "/catalog?q=biz&#{expected_sr_alert}&#{expected_focus_targets}",
        id: "remove-constraint-#{index}"
      )
      expect(subject).to have_selector ".filter-name", text: 'Item Type'
    end

    context 'with string values' do
      subject { helper.render_filter_element('type', 'journal', path, index) }

      let(:expected_sr_alert) { 'sr_alert=Removed%2520Item%2520Type%253A%2520%2522journal%2522%2520from%2520search%2520constraints' }
      let(:expected_focus_targets) { 'focus_target=%255B%2522%2523remove-constraint-0%2522%252C%2520%2522%2523facets%2520.facet-limit%253Afirst-child%2520button%2522%252C%2520%2522%2523facet-panel-collapse-toggle-btn%2522%255D' }

      it "handles string values gracefully" do
        expect(subject).to have_link(
          "Remove constraint Item Type: journal",
          href: "/catalog?q=biz&#{expected_sr_alert}&#{expected_focus_targets}",
          id: "remove-constraint-#{index}"
        )
      end
    end

    context 'with multivalued facets' do
      subject { helper.render_filter_element('type', [%w[journal book]], path, index) }

      let(:expected_sr_alert) { 'sr_alert=Removed%2520Item%2520Type%253A%2520%2522journal%2520OR%2520book%2522%2520from%2520search%2520constraints' }
      let(:expected_focus_targets) { 'focus_target=%255B%2522%2523remove-constraint-0%2522%252C%2520%2522%2523facets%2520.facet-limit%253Afirst-child%2520button%2522%252C%2520%2522%2523facet-panel-collapse-toggle-btn%2522%255D' }

      it "handles such values gracefully" do
        expect(subject).to have_link(
          "Remove constraint Item Type: journal OR book",
          href: "/catalog?q=biz&#{expected_sr_alert}&#{expected_focus_targets}",
          id: "remove-constraint-#{index}"
        )
      end
    end
  end

  describe "#render_constraints_filters" do
    subject { helper.render_constraints_filters(index, params) }

    let(:index) { 1 }
    let(:params) { ActionController::Parameters.new f: { 'type' => [''] } }

    it "renders nothing for empty facet limit param" do
      expect(subject).to be_blank
    end
  end
end
