require "application_system_test_case"

class TosTest < ApplicationSystemTestCase
  test "you have to accept the tos" do
    refute User.find_by(email: 'jane@jane.jane').tos_accepted_at

    visit seminars_path
  
    # Cannot access that page
    assert_selector ".notification", text: "Sie müssen sich anmelden oder registrieren, um fortzufahren."
 
    # Fill in wrong password
    fill_in "E-Mail", with: "jane@jane.jane"
    fill_in "Passwort", with: "test123456"
    find('.actions .button').click #_on "Anmelden"
    assert_selector '.notification', text: "E-Mail oder Passwort ist ungültig."

    # Here we go, correct password
    fill_in "E-Mail", with: "jane@jane.jane"
    fill_in "Passwort", with: "janespassword"
    find('.actions .button').click
    assert_selector '.notification', text: "Datenschutzerklärung und AGB müssen gelesen und zugestimmt werden."

    find('.button_to .button').click

    # Wait for the post-accept redirect to actually land (a raw
    # ActiveRecord check right after .click races the real request/redirect
    # cycle without this) before asserting on DB state.
    assert_selector 'h1', text: 'Veranstaltungsvorschläge für das Ökodorf Sieben Linden'

    assert User.find_by(email: 'jane@jane.jane').tos_accepted_at
  end

  test "if tos already accepted, TOS message is not shown" do
    visit seminars_path
  
    # Here we go, correct password
    fill_in "E-Mail", with: "aunt@old.ie"
    fill_in "Passwort", with: "auntpassword"
    find('.actions .button').click
    assert_selector '.notification', text: "Sie sind nun angemeldet."
  end
end
