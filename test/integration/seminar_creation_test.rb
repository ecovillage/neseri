require 'test_helper'

class SeminarCreationTest < ActionDispatch::IntegrationTest
  test "a full user (tos accepted, profile filled can create seminar" do
    user = users(:fulluser)

    get "/seminars/new"
    assert_response :redirect
    follow_redirect!

    assert_select '.notification-alert' do
      assert_select '.media-content', text: 'Sie müssen sich anmelden oder registrieren, bevor Sie fortfahren können.'
    end

    post "/users/sign_in", params: {
      user: {
        email: user.email,
        password: 'fulluserpassword'
      }
    }
    assert_response :redirect
    follow_redirect!

    assert_select '.notification' do
      assert_select '.media-content', 'Erfolgreich angemeldet.'
    end

    num_seminars = Seminar.count
    get "/seminars/new"
    assert_response :success

    post "/seminars", params: {
      seminar: {
        title: '',
      }
    }

    assert_select '.notification.is-danger' do
      assert_select 'h2', 'Konnte Seminar nicht speichern: ein Fehler.'
    end

    assert_equal num_seminars, Seminar.count

    post "/seminars", params: {
      seminar: {
        title: 'Minimum title',
        start_date: '2020-01-01',
        start_date: '2020-01-02'
      }
    }
    assert_equal num_seminars + 1, Seminar.count

    #assert_equal '', response.body

    assert_response :redirect
    follow_redirect!

    assert_select '.media-content', 'Seminarvorschlag gespeichert'
  end
end
