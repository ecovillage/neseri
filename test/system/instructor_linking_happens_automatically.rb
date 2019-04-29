require "application_system_test_case"

class InstructorLinkingHappensAutomatically < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test "a new, invited user is automatically an instructor (on seminar update)" do
    sign_in users(:admin)

    ## User will be created on invitation
    user_count = User.count
    refute User.find_by(email: 'new@neseri.tu')

    ## Add invited user (add instructor)
    visit edit_seminar_path(seminars(:one))
    click_link_or_button 'Referent/In hinzufügen'
    fill_in 'E-Mail-Adresse', with: 'new@neseri.tu'
    click_link_or_button 'Seminarvorschlag speichern'
    ##assert_response :success

    ## a new user was created.
    assert (user_count + 1) == User.count
    new_user = User.find_by(email: 'new@neseri.tu')
    assert new_user.present?

    assert new_user.teaching_seminars.exists?(seminars(:one).id)
  end

  test "a new, invited user is automatically an instructor (on seminar creation)" do
    sign_in users(:admin)

    ## User will be created on invitation
    user_count = User.count
    refute User.find_by(email: 'newer@neseri.tu')

    ## Add invited user (add instructor)
    visit new_seminar_path(seminars(:one))
    fill_in 'Titel', with: 'New Event'
    click_link_or_button 'Referent/In hinzufügen'
    fill_in 'E-Mail-Adresse', with: 'newer@neseri.tu'
    click_link_or_button 'Neuen Seminarvorschlag anlegen'
    ##assert_response :success

    ## a new user was created.
    assert (user_count + 1) == User.count
    new_user = User.find_by(email: 'newer@neseri.tu')
    assert new_user.present?

    assert new_user.teaching_seminars.exists?(Seminar.find_by(title: 'New Event'))
  end
end
