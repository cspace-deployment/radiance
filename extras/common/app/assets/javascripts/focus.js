/**
 * focus.js
 */

const putFocus = el => {
  return new Promise(resolve => {
    if (el) {
      let counter = 0
      const attemptFocus = setInterval(() => {
        el.focus()
        if (el === document.activeElement || ++counter > 4) {
          // Abort after success or five attempts
          clearInterval(attemptFocus)
          resolve()
        }
      }, 100)
    } else {
      resolve()
    }
  })
}

const onClickBookmarkCheckbox = (e, $thumbnailContainer) => {
  /* 1. Returns focus to the Bookmark checkbox after checking/unchecking.
   * 2. Temporarily adds a class to the container so that the checkbox will remain visible in masonry view
   *    while it waits to receive focus. */
  if ($thumbnailContainer.length) {
    $thumbnailContainer.addClass('toggling-checkbox')
  }
  putFocus(e.target).then(() => {
    if ($thumbnailContainer.length) {
      $thumbnailContainer.removeClass('toggling-checkbox')
    }
  })
}

const setBookmarkCheckboxHandlers = () => {
  const $bookmarkForms = $(Blacklight.doBookmarkToggleBehavior.selector)
  $bookmarkForms.toArray().forEach(el => {
    const document_id = el.getAttribute('data-doc-id')
    const $checkbox = $(`#toggle-bookmark_${document_id}`)
    const $document = $(`[data-document-id="${document_id}"]`).first()
    const $thumbnailContainer = $document.find('.thumbnail-container').first()

    $checkbox.on('click', e => onClickBookmarkCheckbox(e, $thumbnailContainer))
  })
}

Blacklight.onLoad(setBookmarkCheckboxHandlers)
