
document.addEventListener("DOMContentLoaded", () => {
  const elements = document.getElementsByClassName('copy')

  for (let i = 0; i < elements.length; i++) {
    const element = elements.item(i);

    const button = document.createElement('button')

    const icon = document.createElement('i');
    icon.className = 'fa fa-copy'
    button.appendChild(icon)

    button.className = 'button is-primary'
    button.style = 'margin-left: 0.5rem'
    button.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      window.navigator.clipboard.writeText(element.value)

    })

    const wrapper = document.createElement('div')
    element.style = 'min-width: initial' // reset min-width so that there is space for the copy button.
    element.replaceWith(wrapper)
    wrapper.style = 'display: flex'
    wrapper.appendChild(element)
    wrapper.appendChild(button)
  }
});