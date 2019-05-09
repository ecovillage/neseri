class SeminarAdminActions
  include Rails.application.routes.url_helpers
  include ActionPolicy::Behaviour

  authorize :user

  attr_accessor :seminar, :user

  NavigationalItem = Struct.new(:title, :icon, :url, :css_classes, :http_method, keyword_init: true)

  def initialize seminar, user
    @seminar = seminar
    @user    = user
  end

  def items
    return [] if (!@seminar || !@user)
    
    [edit_item, view_user_seminar, create_or_view_admin_copy, lock_or_unlock].compact
  end

  def edit_item
    NavigationalItem.new(title: I18n.t(:edit),
                         icon: 'fa-wrench',
                         css_classes: 'is-primary',
                         url: edit_admin_admin_seminar_path(@seminar)) if allowed_to?(:edit?, @seminar)
  end

  def view_user_seminar
    NavigationalItem.new(title: I18n.t("seminar.view_user_version"),
                         icon: 'fa-eye',
                         css_classes: '',
                         url: @seminar.user_seminar
                        ) if @seminar.user_seminar
  end


  def create_or_view_admin_copy
    if @seminar.is_user_seminar?
      if @seminar.admin_seminar
        view_admin_copy!
      else
        create_admin_copy!
      end
    end
  end

  def lock_or_unlock
    if @seminar.is_user_seminar? && @seminar.active
      if @seminar.locked
        unlock!
      else
        lock!
      end
    end
  end

  private

  def lock!
    NavigationalItem.new(title: I18n.t(:lock),
                         icon: 'fa-lock',
                         css_classes: 'is-link',
                         url: admin_seminar_lock_path(@seminar),
                         http_method: :post
                        )
  end

  def unlock!
    NavigationalItem.new(title: I18n.t(:unlock),
                         icon: 'fa-unlock',
                         css_classes: 'is-info',
                         url: admin_seminar_lock_path(@seminar),
                         http_method: :delete
                        )

  end

  def view_admin_copy!
    NavigationalItem.new(title: I18n.t("seminar.view_admin_copy"),
                         icon: 'fa-eye',
                         css_classes: 'is-warning',
                         url: admin_admin_seminar_path(@seminar.admin_seminar),
                        )
  end

  def create_admin_copy!
    NavigationalItem.new(title: I18n.t("seminar.create_admin_copy"),
                         icon: 'fa-external-link',
                         css_classes: '',
                         url: admin_seminar_admin_copy_path(@seminar),
                         http_method: :post
                        )
  end
end
