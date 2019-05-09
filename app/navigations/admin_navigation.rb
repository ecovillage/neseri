class AdminNavigation < ActionNav::Base
  item :admin do
    title { t(:admin_nav) }
    hide_unless { (allowed_to? :index?, '', with: AdminPolicy) == true }

    item :users do
      title { User.model_name.human(count: 2) }
      url { admin_users_path }
      hide_unless { (allowed_to? :index?, User) == true }
    end

    item :invitation do
      title { t("devise.invitations.new.submit_button") }
      url { new_user_invitation_path }
      hide_unless { (allowed_to? :index?, User) == true }
    end

    item :rooms do
      title { Room.model_name.human(count: 2) }
      url { admin_rooms_path }
      hide_unless { (allowed_to? :index?, Room) == true }
    end

    item :seminar_kinds do
      title { SeminarKind.model_name.human(count: 2) }
      url { admin_seminar_kinds_path }
      hide_unless { (allowed_to? :index?, SeminarKind) == true }
    end

    item :settings do
      title { t('admin.settings') }
      url { admin_settings_path }
      hide_unless { (allowed_to? :index?, :index?, with: AdminPolicy) == true }
    end

    item :emails do
      title { t('admin.mails') }
      url { admin_emails_path }
      hide_unless { (allowed_to? :index?, Ahoy::Message, with: EmailsPolicy) == true }
    end
  end
end

