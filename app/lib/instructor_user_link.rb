class InstructorUserLink

  def self.create_and_invite! instructor
    email = instructor.email

    # TODO That is a pretty nasty conditional and probably not test covered
    if email.nil? && instructor.user
      instructor.email = instructor.user.email
    elsif instructor.user&.email == email
      return
    elsif instructor.user.nil?
      #email && !instructor.user
      if existing_user = User.find_by(email: email)
        instructor.user = existing_user
      else
        invited_user = User.invite!(email: email)
        # User.invite!(email: instructor.email)#, seminar_title: @seminar.title)
        instructor.user = invited_user
      end
    end
  end

  def self.is_correctly_linked? instructor
    instructor.email == instructor.user&.email
  end
end
