/**
 * modal.js
 */

class FocusTrap {
  constructor(modalEl) {
    this.modalEl = modalEl
  }
  activate = (infix = '') => {
    this.#addFocusGuard(`focus-trap-${infix}begin`, this.focusLastDescendant)
    this.#addFocusGuard(`focus-trap-${infix}end`, this.focusFirstDescendant)
  }
  deactivate = (infix = '') => {
    this.#removeFocusGuard(`focus-trap-${infix}begin`, this.focusLastDescendant)
    this.#removeFocusGuard(`focus-trap-${infix}end`, this.focusFirstDescendant)
  }
  focusFirstDescendant = e => {
    const firstFocusable = this.modalEl.querySelector(focusableDescendantsSelector)
    if (e) {
      e.preventDefault()
    }
    putFocus(firstFocusable)
  }
  focusLastDescendant = e => {
    const focusableDescendants = this.modalEl.querySelectorAll(focusableDescendantsSelector)
    if (e) {
      e.preventDefault()
    }
    putFocus(focusableDescendants[focusableDescendants.length - 1])
  }
  // private
  #addFocusGuard = (id, onFocus) => {
    const guardEl = document.getElementById(id)
    if (guardEl) {
      guardEl.setAttribute('tabindex', 0)
      guardEl.addEventListener('focus', onFocus)
    }
  }
  #removeFocusGuard = (id, onFocus) => {
    const guardEl = document.getElementById(id)
    if (guardEl) {
      guardEl.removeAttribute('tabindex', 0)
      guardEl.removeEventListener('focus', onFocus)
    }
  }
}

const focusableDescendantsSelector = ':where(button, input:not([type="hidden"]), textarea, select, a:any-link, *[tabindex]):not([aria-hidden="true"]):not([hidden]):not(disabled):not([id^="focus-trap"])'

const isValidTabindex = v => !Number.isNaN(Number.parseInt(v, 10))

const cacheAriaHidden = el => {
  return new Promise((resolve) => {
    if (el.hasAttribute('aria-hidden')) {
      el.dataset.ariaHidden = el.getAttribute('aria-hidden')
    }
    resolve()
  })
}

const restoreAriaHidden = el => {
  new Promise((resolve) => {
    if (el.dataset.ariaHidden) {
      el.setAttribute('aria-hidden', el.dataset.ariaHidden)
    } else {
      el.removeAttribute('aria-hidden')
    }
    resolve()
  }).then(() => delete el.dataset.ariaHidden)
}

const cacheTabIndex = el => {
  return new Promise((resolve) => {
    if (isValidTabindex(el.tabindex)) {
      el.dataset.tabindex = el.tabindex
    }
    resolve()
  })
}

const restoreTabIndex = el => {
  new Promise((resolve) => {
    if (isValidTabindex(el.dataset.tabindex)) {
      el.setAttribute('tabindex', el.dataset.tabindex)
    } else {
      el.removeAttribute('tabindex')
    }
    resolve()
  }).then(() => delete el.dataset.tabindex)
}

const toggleBackgroundElementsDisabled = (disable, modalId) => {
  /* The modal element is a child of <body>. When the modal opens we need to disable its siblings.
   * Any of these siblings' descendants that can receive focus must also be disabled. */
  const bodyEl = $('body')[0]
  const backgroundElements = Array.from(bodyEl.children)
  backgroundElements.forEach(el => {
    if (['NAV', 'DIV', 'MAIN', 'FOOTER'].includes(el.tagName.toUpperCase()) && ![modalId || 'blacklight-modal'].includes(el.id)) {
      if (disable) {
        const focusableDescendants = Array.from(el.querySelectorAll(focusableDescendantsSelector))
        el.setAttribute('inert', true)
        cacheAriaHidden(el).then(() => el.setAttribute('aria-hidden', true))

        focusableDescendants.forEach(child => {
          child.setAttribute('aria-disabled', true)
          child.setAttribute('disabled', true)
          cacheTabIndex(child).then(() => child.setAttribute('tabindex', -1))
          child.dataset.focusableHidden = true
        })
      } else {
        const focusableDescendants = Array.from(el.querySelectorAll('[data-focusable-hidden]'))
        el.removeAttribute('inert')
        restoreAriaHidden(el)

        focusableDescendants.forEach(child => {
          child.removeAttribute('aria-disabled')
          child.removeAttribute('disabled')
          restoreTabIndex(child)
          delete child.dataset.focusableHidden
        })
      }
    }
  })
}

const onModalShown = e => {
  /* When the modal is open, content outside the modal should not be accessible via
   * keyboard or assistive technology. */
  const modalEl = e.target
  const modalTitle = modalEl.querySelector('#modal-title').textContent
  const focusTrap = new FocusTrap(modalEl)

  focusTrap.focusFirstDescendant()
  focusTrap.activate()
  toggleBackgroundElementsDisabled(true)

  $(modalEl).on('hide.bs.modal', () => {
    onModalWillHide(modalTitle)
    focusTrap.deactivate()
    $(modalEl).off('shown.bs.modal')
  })
}

const onModalWillHide = modalTitle => {
  /* 1. Return the elements outside the modal to their original state.
   * 2. Return focus to the element that triggered the modal. */
  const selector = `:contains("${modalTitle}")`
  const modalTrigger = $(`${Blacklight.modal.triggerLinkSelector}${selector}, ${Blacklight.modal.triggerFormSelector}${selector}`)
  toggleBackgroundElementsDisabled(false)
  putFocus(modalTrigger[0])
}

const onModalInitialized = e => {
  e.target.removeAttribute('aria-hidden')
  $(e.target).on('shown.bs.modal', onModalShown)
}

Blacklight.onLoad(() => {
  $('body').on('loaded.blacklight.blacklight-modal', onModalInitialized)
})
