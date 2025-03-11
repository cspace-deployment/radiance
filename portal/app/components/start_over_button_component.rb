# frozen_string_literal: true

class StartOverButtonComponent < Blacklight::StartOverButtonComponent
  def call
    link_to(
      t('blacklight.search.start_over'),
      start_over_path,
      class: 'catalog_startOverLink btn btn-primary',
      aria: {label: "#{t('blacklight.search.start_over')} Search"}
    )
  end
end
