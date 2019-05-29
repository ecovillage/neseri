class MainNavigation < ActionNav::Base
  item :seminars do
    title { Seminar.model_name.human(count: 2) }
    url   { seminars_path }
    #hide_unless { allowed_to? :index?, Seminar }
    hide_unless { (allowed_to?(:index?, Seminar) && !current_user&.admin) }
  end

  item :contact do
    title { t('pages.contact') }
    url   { contact_path }
  end

  item :impressum do
    title { t('pages.impressum') }
    url   { impressum_path }
  end

  item :privacy do
    title { t('pages.privacy') }
    url   { privacy_path }
  end

  item :about do
    title { t('pages.about') }
    url   { about_path }
  end

  item :documentation do
    title { t('pages.documentation') }
    url   { documentation_path }
    hide_unless { true == current_user&.admin? }
  end
end

