//= require blacklight_gallery/default
//= require blacklight_gallery/osd_viewer

const makeSlideshowAccessible = () => {
  const slideshowModal = document.getElementById('slideshow-modal')
  if (slideshowModal) {
    const slideshowInner = slideshowModal.querySelector('.slideshow-inner')
    slideshowModal.removeAttribute('aria-labelledby')
    slideshowModal.setAttribute('aria-label', 'Search results image carousel')
    if (slideshowInner) {
      const pagination = document.querySelector('#sortAndPerPage .pagination .page-entries')
      const pauseBtn = slideshowModal.querySelector('[data-behavior="pause-slideshow"]')
      const startBtn = slideshowModal.querySelector('[data-behavior="start-slideshow"]')
      const nextLink = slideshowModal.querySelector('[data-slide="next"]')
      const prevLink = slideshowModal.querySelector('[data-slide="prev"]')
      const enableLiveUpdates = () => slideshowInner.setAttribute('aria-live', 'polite')
      const disableLiveUpdates = () => slideshowInner.setAttribute('aria-live', 'off')
      slideshowInner.setAttribute('role', 'region')
      slideshowInner.setAttribute('aria-roledescription', 'slideshow')
      enableLiveUpdates()
      if (pagination) {
        const paginationText = pagination.outerText
        slideshowInner.setAttribute('aria-label', paginationText.replace('-', 'to'))
      }
      if (pauseBtn) {
        pauseBtn.addEventListener('click', enableLiveUpdates)
      }
      if (startBtn) {
        startBtn.addEventListener('click', disableLiveUpdates)
      }
      if (nextLink) {
        nextLink.addEventListener('click', enableLiveUpdates)
      }
      if (prevLink) {
        prevLink.addEventListener('click', enableLiveUpdates)
      }
      Array.from(slideshowInner.children).forEach(el => {
        const count = el.querySelector('.counter')
        if (count) {
          el.setAttribute('aria-label', count.outerText)
        }
      })
    }
  }
}

window.addEventListener('load', makeSlideshowAccessible)
