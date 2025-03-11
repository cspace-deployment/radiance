//= require blacklight_gallery/default
//= require blacklight_gallery/osd_viewer

const observer = new MutationObserver((mutationList) => {
  for (const mutation of mutationList) {
    if (mutation.type === 'attributes' && mutation.attributeName === 'aria-hidden' && mutation.oldValue === 'true') {
      const closeBtn = mutation.target.querySelector('[data-dismiss="modal"]')
      if (closeBtn) {
        setTimeout(() => {
          closeBtn.focus()
        }, 400)
      }
    }
  }
})

const makeSlideshowAccessible = () => {
  const slideshowModal = document.getElementById('slideshow-modal')

  if (slideshowModal) {
    const slideshowInner = slideshowModal.querySelector('.slideshow-inner')
    const pauseBtn = slideshowModal.querySelector('[data-behavior="pause-slideshow"]')
    const startBtn = slideshowModal.querySelector('[data-behavior="start-slideshow"]')

    slideshowModal.removeAttribute('aria-labelledby')
    slideshowModal.setAttribute('aria-label', 'Search results image carousel')
    observer.observe(slideshowModal, {attributes: true, attributeFilter: ['aria-hidden'], attributeOldValue: true})

    if (slideshowInner) {
      const pagination = document.querySelector('#sortAndPerPage .pagination .page-entries')
      slideshowInner.setAttribute('role', 'region')
      slideshowInner.setAttribute('aria-roledescription', 'slideshow')
      if (pagination) {
        const paginationText = pagination.outerText
        slideshowInner.setAttribute('aria-label', paginationText.replace('-', 'to'))
      }
      Array.from(slideshowInner.children).forEach(el => {
        const count = el.querySelector('.counter')
        if (count) {
          el.setAttribute('aria-label', count.outerText)
        }
      })
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
