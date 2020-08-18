require 'rails_helper'

RSpec.feature 'Candidate application choices are delivered to providers' do
  include SignInHelper

  scenario 'the candidate receives an email' do
    given_my_application_is_ready_to_send_to_providers

    when_my_application_is_delivered_to_the_provider

    then_i_should_receive_an_email_saying_my_application_is_under_consideration

    and_i_can_sign_in_to_my_account_via_the_email
  end

  def given_my_application_is_ready_to_send_to_providers
    @application_choice = create(:application_choice, :ready_to_send_to_provider)
  end

  def when_my_application_is_delivered_to_the_provider
    SendApplicationsToProviderWorker.new.perform
  end

  def then_i_should_receive_an_email_saying_my_application_is_under_consideration
    open_email(@application_choice.application_form.candidate.email_address)

    expect(current_email.subject).to end_with(t('candidate_mailer.application_sent_to_provider.subject'))
  end

  def and_i_can_sign_in_to_my_account_via_the_email
    candidate = @application_choice.application_form.candidate
    open_email(candidate.email_address)

    click_magic_link_in_email
    confirm_sign_in

    expect(page).to have_content 'Application dashboard'
  end
end
