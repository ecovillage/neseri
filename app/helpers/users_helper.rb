module UsersHelper
  def user_name user
    if user&.firstname.to_s != '' || user&.lastname.to_s != ''
      "%s %s" % [user.firstname, user.lastname]
    else
      user&.email
    end
  end
end
