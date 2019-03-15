class PagesController < ApplicationController
  def impressum
  end

  def privacy
  end

  def contact
    authenticate_user!
  end

  def about
  end
end
