# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchHistoryConstraintsHelper, type: :helper do
  around { |test| Deprecation.silence(Blacklight::SearchHistoryConstraintsHelperBehavior) { test.call } }

  before(:all) do
    @config = Blacklight::Configuration.new do |config|
      config.add_search_field 'default_search_field', label: 'Default'

      config.add_facet_field 'some_facet', label: 'Some'
      config.add_facet_field 'other_facet', label: 'Other'
      config.add_facet_field 'i18n_facet'

      I18n.backend.store_translations(:en, blacklight: { search: { fields: { facet: { i18n_facet: 'English facet label' } } } })
      I18n.backend.store_translations(:de, blacklight: { search: { fields: { facet: { i18n_facet: 'German facet label' } } } })
    end
  end

  before do
    allow(helper).to receive(:blacklight_config).and_return(@config)
  end

  describe "#render_search_to_s_element" do
    it "overrides Blacklight::SearchHistoryConstraintsHelperBehavior#render_search_to_s_element to render basic element as one item of a definition list" do
      response = helper.render_search_to_s_element("key", "value")

      expect(response).to have_selector("dt.filter-name") do |key|
        expect(key).to have_text("key")
      end
      expect(response).to have_selector("dd.filter-values") do |value|
        expect(value).to have_text("value")
      end
      expect(response).to be_html_safe
    end

    it "escapes them that need escaping" do
      response = helper.render_search_to_s_element("key>", "value>")

      expect(response).to eq '<dt class="filter-name col-6 col-md-5 col-lg-4">key&gt;</dt><dd class="filter-values col-6 col-md-7 col-lg-8 mb-0">value&gt;</dd>'
      expect(response).to be_html_safe
    end

    it "does not escape with options set thus" do
      response = helper.render_search_to_s_element("key>", "value>", escape_key: false, escape_value: false)

      expect(response).to have_selector("dt.filter-name") do |key|
        expect(key).to have_text("key>")
      end
      expect(response).to have_selector("dd.filter-values") do |value|
        expect(value).to have_text("value>")
      end
      expect(response).to be_html_safe
    end
  end

  describe "#render_empty_search" do
    before do
      @params = { q: "" }
    end

    it "overrides default behavior by rendering 'Any field: blank' instead of an empty row" do
      response = helper.render_empty_search(@params)

      expect(response).to have_selector("dt.filter-name") do |key|
        expect(key).to have_text("Any Field")
      end
      expect(response).to have_selector("dd.filter-values .sr-only") do |value|
        expect(value).to have_text("blank")
      end
      expect(response).to be_html_safe
    end
  end

  describe "#render_search_to_s" do
      before do
        @params = { q: "history", f: { "some_facet" => %w[value1 value1], "other_facet" => ["other1"] } }
      end

      it "overrides Blacklight::SearchHistoryConstraintsHelperBehavior#render_search_to_s to render the search string with a unique accessible label" do
        accessible_label = 'recent search 1 of 5'
        response = helper.render_search_to_s(@params, accessible_label)

        expect(response).to have_text(accessible_label)
      end

      it "calls lesser methods" do
        allow(helper).to receive(:blacklight_config).and_return(@config)
        allow(helper).to receive(:default_search_field).and_return(Blacklight::Configuration::SearchField.new(key: 'default_search_field', display_label: 'Default'))
        allow(helper).to receive(:label_for_search_field).with(nil).and_return('')
        # API hooks expect this to be so
        response = helper.render_search_to_s(@params)

        expect(response).to include(helper.render_search_to_s_q(@params))
        expect(response).to include(helper.render_search_to_s_filters(@params))
        expect(response).to be_html_safe
      end
    end
end
