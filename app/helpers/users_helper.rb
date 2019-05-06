module UsersHelper
  def user_name user
    if user&.firstname || user&.lastname
      "%s %s" % [user.firstname, user.lastname]
    else
      user&.email
    end
  end
end
