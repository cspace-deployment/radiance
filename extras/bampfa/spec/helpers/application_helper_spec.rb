# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  let(:mock_response) { instance_double(Blacklight::Solr::Response) }
  let(:mock_document) { instance_double(SolrDocument, export_formats: {}) }
  let(:search_service) { instance_double(Blacklight::SearchService) }

  describe '#bookmark_control_label' do
    subject { helper.bookmark_control_label(document, counter, total) }

    let(:document) { SolrDocument.new(title_s: 'Felix the Cat', idnumber_s: '123-abc') }
    let(:counter) { 5 }
    let(:total) { 20 }

    it 'provides a unique accessible label for the bookmark checkbox' do
      expect(subject).to eq "Felix the Cat, accession number 123-abc. Search result #{counter} of #{total}"
      expect(subject).to be_html_safe
    end
  end

  describe '#document_link_label' do
    let(:label) { 'Felix the Cat' }
    let(:document) { SolrDocument.new(idnumber_s: '123-abc') }

    it 'provides a unique accessible label for the link to a document' do
      expect(helper.document_link_label(document, label)).to eq "Felix the Cat, accession number 123-abc"
    end
  end

  describe '#generate_image_gallery' do
    subject { helper.generate_image_gallery() }

    before do
      allow_any_instance_of(Blacklight::SearchService).to receive(:search_results).and_return(mock_response)
    end

    let(:mock_response) do
      [
        {
          response: {
            docs: documents
          }
        }
      ]
    end
    let(:documents) do
      ids = (1..12).to_a
      ids.map do |id|
        {
          :id => id,
          :title_txt => ["title #{id}"],
          :artistcalc_txt => ["artist #{id}"],
          :datemade_s => "date made #{id}",
          :blob_ss => ["blob-#{id}"],
          :materials_s => "materials #{id}",
          :idnumber_s => "accession number #{id}",
          :itemclass_s => "classification #{id}"
        }
      end
    end

    it 'renders a list of randomly selected documents' do
      documents.each_with_index do |doc, index|
        expected_img_src = "https://webapps.cspace.berkeley.edu/bampfa/imageserver/blobs/#{doc[:blob_ss][0]}/derivatives/Medium/content"
        expected_img_alt = "#{doc[:itemclass_s]} titled #{doc[:title_txt][0]}, #{doc[:materials_s]}, accession number #{doc[:idnumber_s]}."
        expect(subject).to have_link href: "/catalog/#{doc[:id]}" do |link|
          expect(link).to have_selector "img[src=\"#{expected_img_src}\"][alt=\"#{expected_img_alt}\"]"
        end

        item_selector = "div.gallery-item:nth-child(#{index + 1})"
        expect(subject).to have_selector "#{item_selector} .gallery-caption-title", text: doc[:title_txt][0]
        expect(subject).to have_selector "#{item_selector} .gallery-caption-date", text: "(#{doc[:datemade_s]})"
        expect(subject).to have_selector "#{item_selector} .gallery-caption-artist", text: "by #{doc[:artistcalc_txt][0]}"
        expect(subject).to have_link doc[:artistcalc_txt][0], href: "/catalog/?&op=OR&search_field=artistcalc_s&q=\"#{doc[:artistcalc_txt][0].sub(' ', '+')}\""
        expect(subject).to be_html_safe
      end
    end
  end

  describe '#extract_artist_names' do
    pending 'TODO: test with different inputs, multiple artists, etc'
  end

  describe '#format_image_gallery_results' do
    pending 'TODO: test on documents with missing data'
  end

  describe '#render_csid' do
    let(:csid) { 123 }
    let(:derivative) { 'medium' }

    it 'returns an image URL for the given csid and derivative' do
      expect(helper.render_csid(csid, derivative)).to eq "https://webapps.cspace.berkeley.edu/bampfa/imageserver/blobs/#{csid}/derivatives/#{derivative}/content"
    end
  end

  describe '#render_status' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end

  describe '#render_multiline' do
    subject { helper.render_multiline(options) }

    let(:options) { {value: ['life', 'death', 123]} }

    it 'renders an array of values as a list' do
      expect(subject).to have_selector 'div > ul > li:nth-child(1)', text: 'life'
      expect(subject).to have_selector 'div > ul > li:nth-child(2)', text: 'death'
      expect(subject).to have_selector 'div > ul > li:nth-child(3)', text: '123'
      expect(subject).to be_html_safe
    end
  end

  describe '#render_film_links' do
    example 'is skipped', :skip => 'this method is only used by Cinefiles' do
    end
  end

  describe '#render_doc_link' do
    example 'is skipped', :skip => 'this method is only used by Cinefiles' do
    end
  end

  describe '#render_warc' do
    example 'is skipped', :skip => 'this method is only used by Cinefiles' do
    end
  end

  describe '#check_and_render_pdf' do
    example 'is skipped', :skip => 'this method is only used by Cinefiles' do
    end
  end

  describe '#render_alt_text' do
    subject { helper.render_alt_text(blob_csid, document) }

    context 'when object has no data' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({}) }

      it 'provides minimal alt text' do
        expect(subject).to eq 'BAMPFA object no title available, of unknown materials, no accession number available.'
      end
    end

    context 'when object has more than one image' do
      let(:blob_csid) { 2 }
      let(:document) { SolrDocument.new({blob_ss: [1, 2, 3]}) }

      it 'includes image number and total images in the alt text' do
        expect(subject).to eq 'BAMPFA object 2 of 3 no title available, of unknown materials, no accession number available.'
      end
    end

    context 'when object has a classification' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({itemclass_s: 'Ephemera'}) }

      it 'includes the type in the alt text' do
        expect(subject).to eq 'Ephemera no title available, of unknown materials, no accession number available.'
      end
    end

    context 'when object has a title' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({title_txt: ["Kutsal Damacana 2: İtmen"]}) }

      it 'includes the title in the alt text' do
        expect(subject).to eq "BAMPFA object titled Kutsal Damacana 2: İtmen, of unknown materials, no accession number available."
      end
    end

    context 'when object has materials' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({materials_s: 'photogravure'}) }

      it 'includes the title in the alt text' do
        expect(subject).to eq "BAMPFA object no title available, photogravure, no accession number available."
      end
    end

    context 'when object has an accession number' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({idnumber_s: '123-abc'}) }

      it 'includes the title in the alt text' do
        expect(subject).to eq "BAMPFA object no title available, of unknown materials, accession number 123-abc."
      end
    end

    context 'when object has a classification, title, materials, accession number, and more than one image' do
      let(:blob_csid) { 2 }
      let(:document) do
        SolrDocument.new({
          blob_ss: [1, 2, 3],
          itemclass_s: 'Ephemera',
          title_txt: ["Kutsal Damacana 2: İtmen"],
          materials_s: 'photogravure',
          idnumber_s: '123-abc'
        })
      end

      it 'includes them in the alt text' do
        expect(subject).to eq "Ephemera 2 of 3 titled Kutsal Damacana 2: İtmen, photogravure, accession number 123-abc."
      end
    end
  end

  describe '#render_media' do
    subject { helper.render_media(options) }

    let(:blob_csid) { '123abc' }
    let(:document) { SolrDocument.new({}) }
    let(:options) { {document: document, value: [blob_csid]} }
    let(:expected_href) { "https://webapps.cspace.berkeley.edu/bampfa/imageserver/blobs/#{blob_csid}/derivatives/OriginalJpeg/content" }
    let(:expected_img_src) { "https://webapps.cspace.berkeley.edu/bampfa/imageserver/blobs/#{blob_csid}/derivatives/Medium/content" }

    it 'wraps each image in a link to that image' do
      expect(subject).to have_link(href: expected_href)
      expect(subject).to have_selector 'a.d-inline-block > img.thumbclass'
      expect(subject).to be_html_safe
    end

    it "renders each image with alt text " do
      expect(subject).to have_selector("img[src=\"#{expected_img_src}\"]")
      expect(subject).to have_selector("img[alt=\"BAMPFA object no title available, of unknown materials, no accession number available.\"]")
    end
  end

  describe '#render_linkless_media' do
    subject { helper.render_linkless_media(options) }

    let(:blob_csid) { '123abc' }
    let(:document) { SolrDocument.new({}) }
    let(:options) { {document: document, value: [blob_csid]} }
    let(:expected_img_src) { "https://webapps.cspace.berkeley.edu/bampfa/imageserver/blobs/#{blob_csid}/derivatives/Medium/content" }

    it 'does not wrap each image in a link' do
      expect(subject).not_to have_link
      expect(subject).to have_selector 'div.d-inline-block > img.thumbclass'
      expect(subject).to be_html_safe
    end

    it "renders each image with alt text" do
      expect(subject).to have_selector "img[src=\"#{expected_img_src}\"]"
      expect(subject).to have_selector("img[alt=\"BAMPFA object no title available, of unknown materials, no accession number available.\"]")
    end
  end

  describe '#render_restricted_media' do
    subject { helper.render_restricted_media(options) }

    let(:blob_csid) { '123abc' }
    let(:document) { SolrDocument.new({}) }
    let(:options) { {document: document, value: [blob_csid]} }
    let(:expected_img_src) { "https://webapps.cspace.berkeley.edu/bampfa/imageserver/blobs/#{blob_csid}/derivatives/Medium/content" }

    context 'when user is anonymous' do
      it 'renders a placeholder with alt text for each image' do
        expect(subject).not_to have_link
        expect(subject).to have_selector 'div > img.thumbclass'
        expect(subject).to have_selector 'img[src="../kuchar.jpg"]'
        expect(subject).to have_selector 'img[alt="log in to view images"]'
        expect(subject).to be_html_safe
      end
    end

    context 'when user is authenticated' do
      before do
        allow(helper).to receive(:current_user).and_return true
      end

      it 'renders each image with alt text' do
        expect(subject).not_to have_link
        expect(subject).to have_selector 'div > img.thumbclass'
        expect(subject).to have_selector "img[src=\"#{expected_img_src}\"]"
        expect(subject).to have_selector("img[alt=\"BAMPFA object no title available, of unknown materials, no accession number available.\"]")
        expect(subject).to be_html_safe
      end
    end
  end

  describe '#render_audio_csid' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end

  describe '#render_video_csid' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end

  describe '#render_audio_directly' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end

  describe '#render_video_directly' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end

  describe '#render_x3d_csid' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end

  describe '#render_x3d_directly' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end

  describe '#render_ark' do
    example 'is skipped', :skip => 'this method is only used by PAHMA' do
    end
  end
end
