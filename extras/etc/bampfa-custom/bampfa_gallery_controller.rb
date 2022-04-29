class GalleryController < ApplicationController
	include ActionView::Helpers::TagHelper
	include ActionView::Context
	include ApplicationHelper

	include ActionController::MimeResponds
	# helper_method :add_gallery_items
	def add_gallery_items(nextCursorMark="*")
		result = get_random_documents(limit=12,cursorMark=nextCursorMark)
		docs = result[1]
		nextCursorMark = result[0]
		@formatted = format_image_gallery_results(docs, nextCursorMark)
		puts @formatted
		respond_to do |format|
      format.html
			# format.json
      format.js
		end
	end


end
