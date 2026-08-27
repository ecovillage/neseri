// Copy-to-clipboard icons (see CopyHelper#copy_icon).
// Uses event delegation on `document` so it keeps working across
// Turbolinks navigations without needing to (re-)bind listeners on load.
document.addEventListener('click', (event) => {
  const icon = event.target.closest('.copy-icon')
  if (!icon) return

  event.preventDefault()
  event.stopPropagation()
  window.navigator.clipboard.writeText(icon.dataset.copy).then(() => showCopyFeedback(icon))
})

function showCopyFeedback(icon) {
  const symbol = icon.querySelector('i')
  if (!symbol) return

  clearTimeout(icon.copyFeedbackTimeout)

  const originalClass = icon.dataset.originalClass || symbol.className
  icon.dataset.originalClass = originalClass

  symbol.className = 'fa fa-check'
  icon.classList.add('has-text-success')

  icon.copyFeedbackTimeout = setTimeout(() => {
    symbol.className = originalClass
    icon.classList.remove('has-text-success')
  }, 1200)
}
