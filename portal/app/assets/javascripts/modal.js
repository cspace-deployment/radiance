const focusableDescendantsSelector = ':where(button, input:not([type="hidden"]), textarea, select, a:any-link, *[tabindex]):not([aria-hidden="true"]):not([hidden]):not(disabled'

const isValidTabindex = v => !Number.isNaN(Number.parseInt(v, 10))

const toggleBackgroundElementsDisabled = (disable, modalId) => {
  // The modal element is a child of <body>. When the modal opens we need to disable its siblings.
  // Any of these siblings' descendants that can receive focus must also be disabled.
  // If a descendant has a tabindex, capture it in order to restore the element to its original state upon re-enabling.
  const bodyEl = $('body')[0]
  const backgroundElements = Array.from(bodyEl.children)
  backgroundElements.forEach(el => {
    if (['NAV', 'DIV', 'MAIN', 'FOOTER'].includes(el.tagName.toUpperCase()) && modalId !== el.id) {
      if (disable) {
        const focusableDescendants = Array.from(el.querySelectorAll(focusableDescendantsSelector))
        el.setAttribute('inert', true)
        el.setAttribute('aria-hidden', true)
        focusableDescendants.forEach(child => {
          child.setAttribute('aria-disabled', true)
          child.setAttribute('disabled', true)
          child.dataset.focusableHidden = true
          if (isValidTabindex(child.tabindex)) {
            child.dataset.tabindex = child.tabindex
          }
          child.setAttribute('tabindex', -1)
        })
      } else {
        const focusableDescendants = Array.from(el.querySelectorAll('[data-focusable-hidden]'))
        el.removeAttribute('inert')
        el.removeAttribute('aria-hidden')
        focusableDescendants.forEach(child => {
          child.removeAttribute('aria-disabled')
          child.removeAttribute('disabled')
          if (isValidTabindex(child.dataset.tabindex)) {
            child.setAttribute('tabindex', child.dataset.tabindex)
            delete child.dataset.tabindex
          } else {
            child.removeAttribute('tabindex')
          }
          delete child.dataset.focusableHidden
        })
      }
    }
  })
}

const disableContentBehindModal = e => {
  // When the modal is open, content outside the modal should not be accessible via keyboard or assistive technology.
  const modalEl = e.target
  const modalTitle = modalEl.querySelector('#modal-title').textContent
  setTimeout(() => {
    const firstFocusableChild = modalEl.querySelector(focusableDescendantsSelector) || modalEl.querySelector('#blacklight-modal-close')
    if (firstFocusableChild) {
      firstFocusableChild.focus()
      toggleBackgroundElementsDisabled(true, 'blacklight-modal')
    }
  }, 400)
  modalEl.setAttribute('aria-hidden', 'false')
  $(modalEl).on('hide.bs.modal', () => {
    onModalWillHide(modalTitle)
    $(modalEl).off('shown.bs.modal')
  })
}

const onModalWillHide = modalTitle => {
  // Return the elements outside the modal to their original state.
  // Return focus to the element that triggered the modal.
  const selector = `:contains("${modalTitle}")`
  const modalTrigger = $(`${Blacklight.modal.triggerLinkSelector}${selector}, ${Blacklight.modal.triggerFormSelector}${selector}`)
  toggleBackgroundElementsDisabled(false, 'blacklight-modal')
  modalTrigger[0].focus()
}

const onModalShown = e => {
  $(e.target).on('shown.bs.modal', disableContentBehindModal)
}

window.addEventListener('load', () => {
  $('body').on('loaded.blacklight.blacklight-modal', onModalShown)
})
