# frozen_string_literal: true

require 'rails_helper'

describe BlacklightHelper, type: :helper do

  describe "#render_document_heading" do
    around { |test| Deprecation.silence(Blacklight::BlacklightHelperBehavior) { test.call } }

    let(:document) { double }

    before do
      allow(helper).to receive(:presenter).and_return(double(heading: "Heading"))
      # allow(helper).to receive(:render).with('catalog/show_tools').and_return('div class="show-tools"></div>')
    end

    it "overrides Blacklight::BlacklightHelperBehavior#render_document_heading to append the show_tools section to the document heading" do
      expect(helper).to receive(:render).with('catalog/show_tools')
      heading = helper.render_document_heading
    end

    it "accepts no arguments and render the document heading" do
      expect(helper.render_document_heading).to have_selector "h4", text: "Heading"
    end

    it "accepts the tag name as an option" do
      expect(helper.render_document_heading(tag: "h1")).to have_selector "h1", text: "Heading"
    end

    it "accepts an explicit document argument" do
      allow(helper).to receive(:presenter).with(document).and_return(double(heading: "Document Heading"))
      expect(helper.render_document_heading(document)).to have_selector "h4", text: "Document Heading"
    end

    it "accepts the document with a tag option" do
      allow(helper).to receive(:presenter).with(document).and_return(double(heading: "Document Heading"))
      expect(helper.render_document_heading(document, tag: "h3")).to have_selector "h3", text: "Document Heading"
    end
  end
end
