# frozen_string_literal: true

module Gallery
  class SlideshowPreviewComponent < Blacklight::Gallery::SlideshowPreviewComponent

    # populate the thumbnail slot with a value if one wasn't explicitly provided
    def populate_thumbnail_slot
      alt_text = presenter.thumbnail.render_thumbnail_alt_text
      thumbnail_content = presenter.thumbnail.render({ alt: presenter.heading }) if presenter.thumbnail.exists?
      unless thumbnail_content.present?
        thumbnail_content = content_tag(
          :div,
          t(:missing_image, scope: %i[blacklight_gallery catalog grid_slideshow], alt_text: alt_text).html_safe,
          class: 'thumbnail thumbnail-placeholder'
        )
      end
      with_thumbnail(thumbnail_content)
    end
  end
end
