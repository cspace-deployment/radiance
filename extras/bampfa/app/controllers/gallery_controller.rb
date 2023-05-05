class GalleryController < ApplicationController
	include ActionView::Helpers::TagHelper
	include ActionView::Context
	include ApplicationHelper
	include ActionController::MimeResponds

	def add_gallery_items()
		docs = get_random_documents(query: 'blob_ss:[* TO *]')
		@formatted = format_image_gallery_results(docs)
		respond_to do |format|
      format.html
			# format.json
      format.js
		end
	end
end
