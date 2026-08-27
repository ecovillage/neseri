module CopyHelper
  # Renders a small "copy to clipboard" icon for +value+.
  # Returns nil (renders nothing) when +value+ is blank, i.e. nil or an
  # empty/whitespace-only string.
  def copy_icon(value)
    return if value.blank?

    content_tag(:span, class: 'icon is-small copy-icon', title: t(:copy), data: { copy: value }) do
      content_tag(:i, '', class: 'fa fa-copy')
    end
  end
end
