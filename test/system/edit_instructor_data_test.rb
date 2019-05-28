require "application_system_test_case"

class EditInstructorDataTest < ApplicationSystemTestCase
  test "can edit own profile/instructor data" do
    refute User.find_by(email: 'jane@jane.jane').firstname

    visit new_user_session_path
  
    fill_in "E-Mail", with: "aunt@old.ie"
    fill_in "Passwort", with: "auntpassword"
    find('.actions .button').click

    visit edit_instructor_path

    fill_in "Vorname", with: "Alex"
    find('.edit_user .button').click

    assert User.find_by(email: 'aunt@old.ie').firstname
  end
end
