# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  describe '#bookmark_control_label' do
    subject { helper.bookmark_control_label(document, counter, total) }

    let(:document) { SolrDocument.new(objname_s: 'stuff', objmusno_s: 123) }
    let(:counter) { 5 }
    let(:total) { 20 }

    it 'provides a unique accessible label for the bookmark checkbox' do
      expect(subject).to eq "stuff, museum number 123. Search result #{counter} of #{total}"
      expect(subject).to be_html_safe
    end
  end

  describe '#document_link_label' do
    subject { helper.document_link_label(document, label) }

    let(:document) { SolrDocument.new({objmusno_s: '123-abc'}) }
    let(:label) { 'item' }

    it 'provides a unique accessible label for the link to a document' do
      expect(subject).to eq "item, museum number 123-abc"
      expect(subject).to be_html_safe
    end
  end

  describe '#render_csid' do
    let(:csid) { 123 }
    let(:derivative) { 'medium' }

    it 'returns an image URL for the given csid and derivative' do
      expect(helper.render_csid(csid, derivative)).to eq "https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/#{csid}/derivatives/#{derivative}/content"
    end
  end

  describe '#render_status' do
    subject { helper.render_status(options) }

    let(:document) { SolrDocument.new(deaccessioned_s: 'Deaccessioned') }
    let(:options) { {
      document: document,
      field: 'deaccessioned_s',
      value: ['Deaccessioned']
    } }

    it 'handles rendering of object status (i.e. Deaccessioned)' do
      expect(subject).to have_selector '.text-danger', text: 'Deaccessioned'
      expect(subject).to be_html_safe
    end
  end

  describe '#render_multiline' do
    example 'is skipped', :skip => 'this method is only used by Cinefiles' do
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
    subject { helper.render_alt_text(blob_csid, options) }

    context 'when object has no data' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({}) }
      let(:options) { {document: document} }

      it 'provides minimal alt text' do
        expect(subject).to eq 'Hearst Museum object no title available, no object museum number available, no description available. '
      end
    end

    context 'when object has more than one image' do
      let(:blob_csid) { 2 }
      let(:document) { SolrDocument.new({blob_ss: [1, 2, 3]}) }
      let(:options) { {document: document} }

      it 'includes image number and total images in the alt text' do
        expect(subject).to eq 'Hearst Museum object 2 of 3 no title available, no object museum number available, no description available. '
      end
    end

    context 'when object has an image of legacy documentation' do
      let(:blob_csid) { 2 }
      let(:document) { SolrDocument.new({blob_ss: [1, 2, 3]}) }
      let(:options) { {document: document, field: 'card_ss'} }

      it 'describes it as such in the alt text' do
        expect(subject).to eq 'Documentation associated with Hearst Museum object no title available, no object museum number available, no description available. '
      end
    end

    context 'when object has a description' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({objdescr_txt: ["Bha na neoil a' bristeadh, bha na h-achaidhean a' dol am farsuingeachd, agus bha goireasan an taighe a' meudachadh."]}) }
      let(:options) { {document: document} }

      it 'includes the description in the alt text' do
        expect(subject).to eq "Hearst Museum object no title available, no object museum number available, described as Bha na neoil a' bristeadh, bha na h-achaidhean a' dol am farsuingeachd, agus bha goireasan an taighe a' meudachadh. "
      end
    end

    context 'when object image is restricted' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({restrictions_ss: ['notpublic']}) }
      let(:options) { {document: document} }

      it 'includes the restriction notice in the alt text' do
        expect(subject).to eq 'Hearst Museum object no title available, no object museum number available, no description available. Notice: Image restricted due to its potentially sensitive nature. Contact Museum to request access. '
      end
    end

    context 'when object has a title' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({objname_txt: ["Mjallhvít: Æfintýri Handa Börnum"]}) }
      let(:options) { {document: document} }

      it 'includes the title in the alt text' do
        expect(subject).to eq "Hearst Museum object titled Mjallhvít: Æfintýri Handa Börnum, no object museum number available, no description available. "
      end
    end

    context 'when object has a museum number' do
      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({objmusno_txt: ['123abc-7890']}) }
      let(:options) { {document: document} }

      it 'includes the title in the alt text' do
        expect(subject).to eq 'Hearst Museum object no title available, museum number 123abc-7890, no description available. '
      end
    end

    context 'when object has a title, description, and museum number' do
      let(:blob_csid) { 1 }
      let(:document) do
        SolrDocument.new({
          blob_ss: [1],
          objname_txt: ["Mjallhvít: Æfintýri Handa Börnum"],
          objdescr_txt: ["Bha na neoil a' bristeadh, bha na h-achaidhean a' dol am farsuingeachd."],
          objmusno_txt: ['123abc-7890']
        })
      end
      let(:options) { {document: document} }

      it 'includes them in the alt text' do
        expect(subject).to eq "Hearst Museum object titled Mjallhvít: Æfintýri Handa Börnum, museum number 123abc-7890, described as Bha na neoil a' bristeadh, bha na h-achaidhean a' dol am farsuingeachd. "
      end
    end

    context 'when the alt text is for an external link' do
      subject { helper.render_alt_text(blob_csid, options, is_external_link = true) }

      let(:blob_csid) { nil }
      let(:document) { SolrDocument.new({}) }
      let(:options) { {document: document} }

      it "includes 'opens in new tab'" do
        expect(subject).to eq 'Hearst Museum object no title available, no object museum number available, no description available. (opens in new tab)'
      end
    end
  end

  describe '#render_media' do
    subject { helper.render_media(options) }

    let(:blob_csid) { '123abc' }
    let(:document) { SolrDocument.new({}) }
    let(:options) { {document: document, value: [blob_csid]} }
    let(:expected_href) { "https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/#{blob_csid}/derivatives/OriginalJpeg/content" }
    let(:expected_img_src) { "https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/#{blob_csid}/derivatives/Medium/content" }

    it 'wraps each image in a link to that image' do
      expect(subject).to have_link(href: expected_href)
      expect(subject).to have_selector 'a.d-inline-block > img.thumbclass'
      expect(subject).to be_html_safe
    end

    it "renders each image with alt text that includes 'opens in new tab'" do
      expect(subject).to have_selector("img[src=\"#{expected_img_src}\"]")
      expect(subject).to have_selector("img[alt=\"Hearst Museum object no title available, no object museum number available, no description available. (opens in new tab)\"]")
    end
  end

  describe '#render_linkless_media' do
    example 'is skipped', :skip => 'this method is only used by Cinefiles' do
    end
  end

  describe '#render_restricted_media' do
    example 'is skipped', :skip => 'this method is only used by Cinefiles' do
    end
  end

  describe '#render_audio_csid' do
    subject { helper.render_audio_csid(options) }

    let(:audio_csid) { '123abc' }
    let(:options) { {value: [audio_csid]} }
    let(:expected_audio_src) { "https://portal.hearstmuseum.berkeley.edu/cspace-services/blobs/#{audio_csid}/content" }

    it 'renders an audio player using authenticating proxy and blob csid to serve audio' do
      expect(subject).to have_selector 'div > audio[controls="controls"] > source[id="audio_csid"]'
      expect(subject).to have_selector 'div > audio > source[type="audio/mpeg"]'
      expect(subject).to have_selector "div > audio > source[src=\"#{expected_audio_src}\"]"
      expect(subject).to have_text "I'm sorry; your browser doesn't support HTML5 audio in MPEG format."
      expect(subject).to be_html_safe
    end
  end

  describe '#render_video_csid' do
    subject { helper.render_video_csid(options) }

    let(:video_csid) { '123abc' }
    let(:options) { {value: [video_csid]} }
    let(:expected_video_src) { "https://portal.hearstmuseum.berkeley.edu/cspace-services/blobs/#{video_csid}/content" }

    it 'renders a video player using authenticating proxy and blob csid to serve video' do
      expect(subject).to have_selector 'div > video[controls="controls"] > source[id="video_csid"]'
      expect(subject).to have_selector 'div > video > source[type="video/mp4"]'
      expect(subject).to have_selector "div > video > source[src=\"#{expected_video_src}\"]"
      expect(subject).to have_text "I'm sorry; your browser doesn't support HTML5 video in MP4 with H.264."
      expect(subject).to be_html_safe
    end
  end

  describe '#render_audio_directly' do
    subject { helper.render_audio_directly(options) }

    let(:audio_md5) { '123abc' }
    let(:options) { {value: [audio_md5]} }
    let(:expected_audio_src) { "https://cspace-prod-02.ist.berkeley.edu/pahma_nuxeo/data/12/3a/#{audio_md5}" }

    it 'renders an audio player serving audio directy via apache' do
      expect(subject).to have_selector 'div > audio[controls="controls"] > source[id="audio_md5"]'
      expect(subject).to have_selector 'div > audio > source[type="audio/mpeg"]'
      expect(subject).to have_selector "div > audio > source[src=\"#{expected_audio_src}\"]"
      expect(subject).to have_text "I'm sorry; your browser doesn't support HTML5 audio in MPEG format."
      expect(subject).to be_html_safe
    end
  end

  describe '#render_video_directly' do
    subject { helper.render_video_directly(options) }

    let(:video_md5) { '123abc' }
    let(:options) { {value: [video_md5]} }
    let(:expected_video_src) { "https://cspace-prod-02.ist.berkeley.edu/pahma_nuxeo/data/12/3a/#{video_md5}" }

    it 'renders a video player serving video directy via apache' do
      expect(subject).to have_selector 'div > video[controls="controls"] > source[id="video_md5"]'
      expect(subject).to have_selector 'div > video > source[type="video/mp4"]'
      expect(subject).to have_selector "div > video > source[src=\"#{expected_video_src}\"]"
      expect(subject).to have_text "I'm sorry; your browser doesn't support HTML5 video in MP4 with H.264."
      expect(subject).to be_html_safe
    end
  end

  describe '#render_x3d_csid' do
    subject { helper.render_x3d_csid(options) }

    let(:x3d_csid) { '123abc' }
    let(:document) { SolrDocument.new({}) }
    let(:options) { {document: document, value: [x3d_csid]} }
    let(:expected_x3d_src) { "https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/#{x3d_csid}/content" }

    it 'renders an X3D element using authenticating proxy and blob csid to serve 3-D image' do
      expect(subject).to have_selector 'div > x3d[role="img"] > scene > inline[type="model/x3d+xml"]'
      expect(subject).to have_selector "div > x3d.x3d-object > scene > inline[url=\"#{expected_x3d_src}\"]"
      expect(subject).to have_selector 'div > x3d[aria-label="Hearst Museum object no title available, no object museum number available, no description available. "] > scene > inline[id="x3d"]'
      expect(subject).to be_html_safe
    end
  end

  describe '#render_x3d_directly' do
    subject { helper.render_x3d_directly(options) }

    let(:x3d_md5) { '123abc' }
    let(:document) { SolrDocument.new({}) }
    let(:options) { {document: document, value: [x3d_md5]} }
    let(:expected_x3d_src) { "https://cspace-prod-02.ist.berkeley.edu/pahma_nuxeo/data/12/3a/#{x3d_md5}" }

    it 'renders an X3D element serving a 3-D image directy via apache' do
      expect(subject).to have_selector 'div > x3d[role="img"] > scene > inline[type="model/x3d+xml"]'
      expect(subject).to have_selector "div > x3d.x3d-object > scene > inline[url=\"#{expected_x3d_src}\"]"
      expect(subject).to have_selector 'div > x3d[aria-label="Hearst Museum object no title available, no object museum number available, no description available. "] > scene > inline[class="x3d"]'
      expect(subject).to be_html_safe
    end
  end

  describe '#render_ark' do
    subject { helper.render_ark(options) }

    let(:options) { {value: museum_numbers} }
    let(:museum_numbers) { ['11-4461.1', '26-674a,b', 'L-19463'] }
    let(:expected_link_text) { ['ark:/21549/hm211104461@2e1', 'ark:/21549/hm21260674a@2cb', 'ark:/21549/hm210l0019463'] }

    it 'computes ark from museum number and renders as a permalink' do
      museum_numbers.each_with_index do |musno, index|
        expect(subject).to have_link expected_link_text[index], href: "https://n2t.net/#{expected_link_text[index]}" do |link|
          expect(link['aria-label']).to eq "permalink: #{expected_link_text[index]}"
        end
      end
    end
  end
end
