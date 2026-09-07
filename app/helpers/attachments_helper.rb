module AttachmentsHelper
  # Renders a small thumbnail for an attached image, the same way
  # `image_tag file.variant(resize: ...).processed` would - except that
  # `.processed` reads the original file to generate the variant, which
  # raises ActiveStorage::FileNotFoundError if that file is missing on disk
  # (e.g. a database restored without its matching Active Storage files).
  # Left unguarded, that exception bubbles up as a view error and 500s the
  # whole page for every visitor, no matter how unrelated their request was
  # to the missing file. Rescue it here and show a placeholder instead.
  def attachment_thumbnail(file, resize: "180x100")
    image_tag file.variant(resize: resize).processed
  rescue ActiveStorage::FileNotFoundError
    content_tag(:span, class: "icon has-text-warning", title: t("seminar.file_missing")) do
      content_tag(:i, "", class: "fa fa-warning")
    end
  end
end
