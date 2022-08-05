class GalleryController < ApplicationController
	include ActionView::Helpers::TagHelper
	include ActionView::Context
	include ApplicationHelper

	include ActionController::MimeResponds
	# helper_method :add_gallery_items
	def add_gallery_items
		docs = get_random_documents(query: 'blob_ss:[* TO *]')
		@formatted = format_image_gallery_results(docs)
		# puts @formatted
		respond_to do |format|
      format.html
			# format.json
      format.js
		end
	end


end
