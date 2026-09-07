require "application_system_test_case"

class RegistrationTest < ApplicationSystemTestCase
  test "a new user can register via 'Neu registrieren'" do
    refute User.find_by(email: 'newperson@neseri.de')

    visit root_path
    click_link_or_button 'neu registrieren'

    assert_selector 'h2', text: 'Neu registrieren'

    fill_in 'E-Mail', with: 'newperson@neseri.de'
    fill_in 'Passwort', with: 'newpersonpassword'
    fill_in 'Passwortbestätigung', with: 'newpersonpassword'
    check 'AGB und Datenschutzerklärung gelesen und akzeptiert', allow_label_click: true
    find('.actions .button').click

    assert_selector '.notification', text: 'Bestätigungs-E-Mail'

    assert User.find_by(email: 'newperson@neseri.de')
  end
end
