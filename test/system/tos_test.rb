require "application_system_test_case"

class TosTest < ApplicationSystemTestCase
  test "you have to accept the tos" do
    refute User.find_by(email: 'jane@jane.jane').tos_accepted_at

    visit seminars_path
  
    # Cannot access that page
    assert_selector ".notification", text: "Sie müssen sich anmelden oder registrieren, bevor Sie fortfahren können."
 
    # Fill in wrong password
    fill_in "E-Mail", with: "jane@jane.jane"
    fill_in "Passwort", with: "test123456"
    find('.actions .button').click #_on "Anmelden"
    assert_selector '.notification', text: "E-Mail oder Passwort ungültig"

    # Here we go, correct password
    fill_in "E-Mail", with: "jane@jane.jane"
    fill_in "Passwort", with: "janespassword"
    find('.actions .button').click
    assert_selector '.notification', text: "Datenschutzerklärung und AGB müssen gelesen und zugestimmt werden."

    find('.button_to .button').click

    assert User.find_by(email: 'jane@jane.jane').tos_accepted_at
  end

  test "if tos already accepted, TOS message is not shown" do
    visit seminars_path
  
    # Here we go, correct password
    fill_in "E-Mail", with: "aunt@old.ie"
    fill_in "Passwort", with: "auntpassword"
    find('.actions .button').click
    assert_selector '.notification', text: "Erfolgreich angemeldet."
  end
end
