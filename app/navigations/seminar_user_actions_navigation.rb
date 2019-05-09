class SeminarUserActionsNavigation < ActionNav::Base
  item :edit do
    hide_unless { (allowed_to? :edit?, @seminar) == true }
    url { edit_seminar_path(@seminar) }
    title { I18n.t(:edit) }
    icon "fa-wrench"
  end

  item :copy do
    hide_unless { (allowed_to? :show?, @seminar) == true }
    url { seminar_clone_path(@seminar) }
    title { I18n.t(:clone) }
    icon "fa-clone"
    description "post is-link"
  end

  item :new do
    hide_unless { (allowed_to? :destroy?, @seminar) == true }
    url { new_seminar_path() }
    title { I18n.t('seminar.new') }
    icon "fa-plus-circle"
  end
end
