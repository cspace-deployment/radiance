/**
 * slideshow_modal.js
 */

class Slideshow {
  constructor(modalEl) {
    this.modalEl = modalEl
    this.slideshowInner = document.getElementById('slideshow-inner')
    this.nextLink = modalEl.querySelector('[data-slide="next"]')
    this.prevLink = modalEl.querySelector('[data-slide="prev"]')
    this.pauseBtn = modalEl.querySelector('[data-behavior="pause-slideshow"]')
    this.startBtn = modalEl.querySelector('[data-behavior="start-slideshow"]')
    this.init()
  }
  init = () => {
    this.#transport()
    this.#setLabel()
    if (this.pauseBtn && this.startBtn) {
      this.pauseBtn.addEventListener('click', this.onSlideshowPaused)
      this.startBtn.addEventListener('click', this.onSlideshowStarted)
    }
    if (this.nextLink) {
      this.nextLink.addEventListener('click', this.onSlideshowPaused)
    }
    if (this.prevLink) {
      this.prevLink.addEventListener('click', this.onSlideshowPaused)
    }
  }
  onSlideshowPaused = e => {
    this.slideshowInner.setAttribute('aria-live', 'polite')
    this.startBtn.removeAttribute('disabled')
    if (e && e.type === 'click') {
      putFocus(this.startBtn)
    }
    setTimeout(() => this.pauseBtn.setAttribute('disabled', true), 100)
  }
  onSlideshowStarted = () => {
    this.slideshowInner.setAttribute('aria-live', 'off')
    this.pauseBtn.removeAttribute('disabled')
    putFocus(this.pauseBtn)
    setTimeout(() => this.startBtn.setAttribute('disabled', true), 100)
  }
  // private
  #setLabel = () => {
    const pagination = document.querySelector('#sortAndPerPage .pagination .page-entries')
    if (pagination) {
      const paginationText = pagination.outerText
      this.slideshowInner.setAttribute('aria-label', paginationText.replace('-', 'to'))
    }
  }
  #transport = () => {
    // Transport the modal within the DOM to facilitate disabling the background elements
    const bodyEl = $('body')[0]
    bodyEl.appendChild(this.modalEl)
  }
}

const onSlideshowModalShown = (slideshow) => {
  const focusTrap = new FocusTrap(slideshow.modalEl)
  focusTrap.focusFirstDescendant()
  focusTrap.activate('slideshow-')
  toggleBackgroundElementsDisabled(true, 'slideshow-modal')
  slideshow.modalEl.removeAttribute('aria-hidden')
  if (slideshow.startBtn && slideshow.pauseBtn) {
    slideshow.onSlideshowPaused()
  }

  $(slideshow.modalEl).on('hide.bs.modal', () => {
    onSlideshowModalWillHide()
    focusTrap.deactivate('slideshow-')
  })
}

const onSlideshowModalWillHide = () => {
  toggleBackgroundElementsDisabled(false, 'slideshow-modal')
}

const onSlideshowLoaded = () => {
  const modalEl = document.getElementById('slideshow-modal')
  if (modalEl) {
    const slideshow = new Slideshow(modalEl)
    $(modalEl).on('shown.bs.modal', () => onSlideshowModalShown(slideshow))
  }
}

window.addEventListener('load', onSlideshowLoaded)
