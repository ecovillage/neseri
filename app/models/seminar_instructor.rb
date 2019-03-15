class SeminarInstructor < ApplicationRecord
  belongs_to :seminar
  belongs_to :instructor
end
