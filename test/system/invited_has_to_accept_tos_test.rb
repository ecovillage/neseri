require "application_system_test_case"

class InvitedHasToAcceptTosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test "an invited has to accept tos to create user" do
    sign_in users(:admin)

    # User will be created on invitation
    user_count = User.count
    refute User.find_by(email: 'jones@neseri.tu')
    assert_equal 0, ActionMailer::Base.deliveries.count

    # Add invited user (add instructor)
    visit edit_seminar_path(seminars(:one))
    assert_selector "h1", text: "Vorschlag bearbeiten"
                       # 'Referent/In hinzufügen'
    click_link_or_button 'Referent/In hinzufügen'
    fill_in 'E-Mail-Adresse', with: 'jones@neseri.tu'
    click_link_or_button 'Seminarvorschlag speichern'
    #assert_response :success

    # a new user was created.
    assert (user_count + 1) == User.count
    jones = User.find_by(email: 'jones@neseri.tu')
    assert jones

    # log out as admin
    sign_out users(:admin)


    # Follow invitation link as jones.
    # click the link but you have to accept tos/terms.
    visit 'users/invitation/accept?invitation_token=hns-dvpnWby-TsLD-AnK'
    assert_selector '.notification', text: 'Der Einladungslink ist ungültig'

    # Mail has been sent
    mail = ActionMailer::Base.deliveries.last
    mail_body = mail.body.parts[0].decoded
    # e.g. http://localhost/users/invitation/accept?invitation_token=yySnSWtD8ERZWDPNkW6s\r
    /^http:\/\/localhost\/(?<invitation_path>.*)/ =~ mail_body

    visit invitation_path

    refute_selector '.notification', text: 'Der Einladungslink ist ungültig'
    fill_in 'Passwort', with: 'jones@neseri.tu'
    fill_in 'Passwortbestätigung', with: 'jones@neseri.tu'
    find('.actions .button').click

    assert_selector '.notification', text: "Benutzer/In konnte aufgrund eines Fehlers nicht gespeichert werden:\nDatenschutz und AGB muss akzeptiert werden"

    fill_in 'Passwort', with: 'jones@neseri.tu'
    fill_in 'Passwortbestätigung', with: 'jones@neseri.tu'
    check "AGB und Datenschutzerklärung gelesen und akzeptiert", allow_label_click: true
    find('.actions .button').click

    assert_selector '.notification', text: 'Passwort geändert. Du bist nun eingeloggt.'
  end
end
