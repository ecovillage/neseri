# BulmaFormBuilder's HorizontalBulmaFormBuilder#bulma_label derives both
# the visible label text and the HTML `for=` attribute from the same
# attribute name, so a custom label string passed via `label:` (e.g.
# "Vorname *") ends up as a broken `for="user_Vorname *"` that no longer
# matches the field's real id. This subclass keeps `for=` correct and only
# adds a '*' to the label text of fields required on this form.
class SignUpFormBuilder < BulmaFormBuilder::HorizontalBulmaFormBuilder
  REQUIRED_FIELDS = %i[email firstname lastname phone password password_confirmation].freeze

  def bulma_label(attr_name)
    div_with_class('field-label is-normal') do
      next unless attr_name.present?

      text = object.class.human_attribute_name(attr_name)
      text += ' *' if REQUIRED_FIELDS.include?(attr_name.to_sym)
      label(attr_name, text, class: 'label')
    end
  end
end
