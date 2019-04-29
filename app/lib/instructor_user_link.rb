class InstructorUserLink
  def self.create instructor
    email = instructor.email

    if instructor.user&.email == email
      return
    elsif
      email && !instructor.user
      if user = User.find_by(email: email)
        instructor.user = user
      end
    end
  end

  def self.is_correctly_linked? instructor
    instructor.email == instructor.user&.email
  end
end
