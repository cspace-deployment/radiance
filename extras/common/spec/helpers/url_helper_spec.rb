# frozen_string_literal: true

require 'rails_helper'

describe UrlHelper do
  around { |test| Deprecation.silence(described_class) { test.call } }

  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.index.title_field = 'title_tsim'
      config.index.display_type_field = 'format'
    end
  end

  let(:parameter_class) { ActionController::Parameters }

  describe "#with_screen_reader_alert" do
    let(:url) { 'test.berkeley.edu' }

    it "adds query parameter 'sr_alert' to a URL" do
      decorated_url = helper.with_screen_reader_alert(url, 'hello, screen reader')
      expect(decorated_url).to eq 'test.berkeley.edu?sr_alert=hello%252C%2520screen%2520reader'
    end

    it "adds query parameters 'sr_alert' and 'focus_target' to a URL" do
      decorated_url = helper.with_screen_reader_alert(url, 'hello, screen reader', '#element-id')
      expect(decorated_url).to eq 'test.berkeley.edu?sr_alert=hello%252C%2520screen%2520reader&focus_target=%2523element-id'
    end

    it "appends to a URL with existing query parameters" do
      url = 'test.berkeley.edu?foo=bar'

      decorated_url = helper.with_screen_reader_alert(url, 'hello, screen reader', '#element-id')
      expect(decorated_url).to eq 'test.berkeley.edu?foo=bar&sr_alert=hello%252C%2520screen%2520reader&focus_target=%2523element-id'
    end

    it "handles a list of focus targets" do
      focus_targets = [
        '#element-id',
        '.element-class',
        'a > #complex .element.selector'
      ]
      decorated_url = helper.with_screen_reader_alert(url, 'hello, screen reader', focus_targets)
      expect(decorated_url).to eq 'test.berkeley.edu?sr_alert=hello%252C%2520screen%2520reader&focus_target=%255B%2522%2523element-id%2522%252C%2520%2522.element-class%2522%252C%2520%2522a%2520%253E%2520%2523complex%2520.element.selector%2522%255D'
    end
  end

  describe "#link_to_previous_search" do
    before do
      allow(helper).to receive(:url_for).with({:action=>"catalog", :q=>'search query'}).and_return('/catalog?q=search%2520query')
      allow(helper).to receive(:url_for).with('/catalog?q=search%2520query').and_return('/catalog?q=search%2520query')
    end

    let(:params) { { q: 'search query' } }

    it "overrides Blacklight::UrlHelperBehavior#link_to_previous_search to add class=\"d-block\"" do
      expect(helper.link_to_previous_search(params)).to have_css('a.d-block')
    end

    it "overrides Blacklight::UrlHelperBehavior#link_to_previous_search to add an optional accessible label" do
      accessible_label = 'recent search 1 of 3: '
      expect(helper.link_to_previous_search(params, accessible_label)).to have_text(accessible_label)
    end

    it "links to the given search parameters" do
      allow(helper).to receive(:render_search_to_s).with(params, '').and_return "link text"
      expect(helper.link_to_previous_search(params)).to have_link("link text", :href => helper.search_action_path(params))
    end
  end

  describe "link_to_document" do
    let(:title_tsim) { '654321' }
    let(:id) { '123456' }
    let(:data) { {
      'id' => id,
      'title_tsim' => [title_tsim],
      'film_year_i' => '1999',
      'film_director_ss' => ['Skärnheim Vim']
    } }
    let(:document) { SolrDocument.new(data) }

    before do
      allow(controller).to receive(:action_name).and_return('index')
      allow(helper.main_app).to receive(:respond_to?).with('track_test_path').and_return(true)
      allow(helper.main_app).to receive(:respond_to?).with(:track_test_path).and_return(true)
      allow(helper.main_app).to receive(:respond_to?).with(:track_test_path, true).and_return(true)
      allow(helper.main_app).to receive(:track_test_path).and_return('tracking url')
      # allow(helper).to receive(:document_link_params).with(document, {:counter=>nil}).and_return({:data=>{:"context-href"=>"tracking url"}})
      # allow(helper).to receive(:document_link_params).with(document, {:counter=>5}).and_return({:data=>{:"context-href"=>"tracking url"}})
    end

    it "overrides Blacklight::UrlHelperBehavior#link_to_document to add unique accessible label to the document link" do
      link = helper.link_to_document document, :title_tsim
      expect(link).to have_selector '[aria-label]'
    end

    it "consists of the document title wrapped in a <a>" do
      allow(Deprecation).to receive(:warn)
      expect(helper.link_to_document(document, :title_tsim)).to have_selector("a", text: '654321', count: 1)
    end

    it "accepts and returns a string label" do
      expect(helper.link_to_document(document, 'This is the title')).to have_selector("a", text: 'This is the title', count: 1)
    end

    it "accepts and returns a Proc" do
      allow(Deprecation).to receive(:warn)
      expect(helper.link_to_document(document, proc { |doc, _opts| doc[:id] + ": " + doc.first(:title_tsim) })).to have_selector("a", text: '123456: 654321', count: 1)
    end

    context 'when label is missing' do
      let(:data) { { 'id' => id } }

      it "returns id" do
        allow(Deprecation).to receive(:warn)
        expect(helper.link_to_document(document, :title_tsim)).to have_selector("a", text: '123456', count: 1)
      end

      it "is html safe" do
        allow(Deprecation).to receive(:warn)
        expect(helper.link_to_document(document, :title_tsim)).to be_html_safe
      end

      it "passes on the title attribute to the link_to_with_data method" do
        expect(helper.link_to_document(document, "Some crazy long label...", title: "Some crazy longer label")).to match(/title="Some crazy longer label"/)
      end

      it "doesn't add an erroneous title attribute if one isn't provided" do
        expect(helper.link_to_document(document, "Some crazy long label...")).not_to match(/title=/)
      end

      context "with an integer id" do
        let(:id) { 123_456 }

        it "works" do
          expect(helper.link_to_document(document)).to have_selector("a")
        end
      end
    end

    it "converts the counter parameter into a data- attribute" do
      allow(Deprecation).to receive(:warn)
      expect(helper.link_to_document(document, :title_tsim, counter: 5)).to include 'data-context-href="tracking url"'

      # This fails, I think because I had to mock `respond_to?` :track_test_path multiple times to get other tests to pass.
      # expect(helper.main_app).to have_received(:track_test_path).with(hash_including(id: have_attributes(id: '123456'), counter: 5))
    end

    it "includes the data- attributes from the options" do
      link = helper.link_to_document document, data: { x: 1 }
      expect(link).to have_selector '[data-x]'
    end

    it 'adds a controller-specific tracking attribute' do
      allow(helper.main_app).to receive(:track_test_path).and_return('/asdf')
      link = helper.link_to_document document, data: { x: 1 }

      expect(link).to have_selector '[data-context-href="/asdf"]'
    end
  end
end
