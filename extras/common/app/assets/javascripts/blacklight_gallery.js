//= require blacklight_gallery/default
//= require blacklight_gallery/osd_viewer

const onSlideshowModalShown = (modalEl) => {
  const closeBtn = modalEl.querySelector('[data-dismiss="modal"]')
  toggleBackgroundElementsDisabled(true, 'slideshow-modal')
  if (closeBtn) {
    setTimeout(() => {
      closeBtn.focus()
    }, 400)
  }
}

const onSlideshowModalWillHide = () => {
  toggleBackgroundElementsDisabled(false, 'slideshow-modal')
}

const makeSlideshowAccessible = () => {
  const slideshowModal = document.getElementById('slideshow-modal')
  if (slideshowModal) {
    const slideshowInner = document.getElementById('slideshow-inner')
    const pauseBtn = slideshowModal.querySelector('[data-behavior="pause-slideshow"]')
    const startBtn = slideshowModal.querySelector('[data-behavior="start-slideshow"]')
    const bodyEl = $('body')[0]
    // Transport the modal within the DOM to facilitate disabling the background elements
    bodyEl.appendChild(slideshowModal)

    $(slideshowModal).on('shown.bs.modal', () => onSlideshowModalShown(slideshowModal))
    $(slideshowModal).on('hide.bs.modal', onSlideshowModalWillHide)

    if (slideshowInner) {
      const pagination = document.querySelector('#sortAndPerPage .pagination .page-entries')
      if (pagination) {
        const paginationText = pagination.outerText
        slideshowInner.setAttribute('aria-label', paginationText.replace('-', 'to'))
      }
    }
    if (pauseBtn && startBtn) {
      const nextLink = slideshowModal.querySelector('[data-slide="next"]')
      const prevLink = slideshowModal.querySelector('[data-slide="prev"]')
      const onSlideshowPaused = () => {
        startBtn.removeAttribute('aria-disabled')
        pauseBtn.setAttribute('aria-disabled', true)
        slideshowInner.setAttribute('aria-live', 'polite')
      }
      const onSlideshowStarted = () => {
        pauseBtn.removeAttribute('aria-disabled')
        startBtn.setAttribute('aria-disabled', true)
        slideshowInner.setAttribute('aria-live', 'off')
      }
      onSlideshowPaused()
      pauseBtn.addEventListener('click', onSlideshowPaused)
      startBtn.addEventListener('click', onSlideshowStarted)
      if (nextLink) {
        nextLink.addEventListener('click', onSlideshowPaused)
      }
      if (prevLink) {
        prevLink.addEventListener('click', onSlideshowPaused)
      }
    }
  }
}

window.addEventListener('load', makeSlideshowAccessible)
