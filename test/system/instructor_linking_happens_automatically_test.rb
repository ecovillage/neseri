require "application_system_test_case"

class InstructorLinkingHappensAutomaticallyTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test "a new, invited user is automatically an instructor (on seminar update)" do
    sign_in users(:admin)

    ## User will be created on invitation
    user_count = User.count
    refute User.find_by(email: 'new@neseri.de')

    ## Add invited user (add instructor) on an admin copy (admin can only
    ## edit admin copies, not other users' plain seminars - see SeminarPolicy)
    visit edit_seminar_path(seminars(:admin_copy_bob_and_janes_seminar))
    click_link_or_button 'Referent*in hinzufügen'
    fill_in 'E-Mail-Adresse', with: 'new@neseri.de'
    fill_in 'Vorname', with: 'New'
    fill_in 'Nachname', with: 'Person'
    fill_in 'Adresse', with: 'Musterstraße 1, 12345 Musterstadt'
    fill_in 'Telefonnummer', with: '0123456789'
    click_link_or_button 'Seminarvorschlag speichern'

    # Wait for the redirect to actually land before checking DB state.
    assert_selector '.notification', text: 'Seminarvorschlag gespeichert'

    ## a new user was created.
    assert (user_count + 1) == User.count
    new_user = User.find_by(email: 'new@neseri.de')
    assert new_user.present?

    assert new_user.teaching_seminars.exists?(seminars(:admin_copy_bob_and_janes_seminar).id)
  end

  test "a new, invited user is automatically an instructor (on seminar creation)" do
    sign_in users(:admin)

    ## User will be created on invitation
    user_count = User.count
    refute User.find_by(email: 'newer@neseri.de')

    ## Add invited user (add instructor)
    visit new_seminar_path
    fill_in 'Titel', with: 'New Event'

    # Reveal the (JS-hidden-by-default) costs section and fill in the
    # required cost_participant field.
    find('#tab-title-in-person-seminar').click
    fill_in 'Seminarkosten für Teilnehmer*in', with: '100'

    click_link_or_button 'Referent*in hinzufügen'
    fill_in 'E-Mail-Adresse', with: 'newer@neseri.de'
    fill_in 'Vorname', with: 'Newer'
    fill_in 'Nachname', with: 'Person'
    fill_in 'Adresse', with: 'Musterstraße 1, 12345 Musterstadt'
    fill_in 'Telefonnummer', with: '0123456789'
    check 'Ich akzeptiere diese Konditionen', allow_label_click: true
    click_link_or_button 'Neuen Seminarvorschlag anlegen'

    # Wait for the redirect to actually land before checking DB state.
    assert_selector '.notification', text: 'Seminarvorschlag gespeichert'

    ## a new user was created.
    assert (user_count + 1) == User.count
    new_user = User.find_by(email: 'newer@neseri.de')
    assert new_user.present?

    assert new_user.teaching_seminars.exists?(Seminar.find_by(title: 'New Event').id)
  end
end
