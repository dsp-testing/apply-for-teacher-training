require 'rails_helper'

RSpec.feature 'See Duplicate candidate matches' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2021, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'Support agent visits Duplicate candidate matches page', sidekiq: true do
    given_i_am_a_support_user
    and_the_duplicate_matching_feature_flag_is_inactive
    and_i_go_to_duplicate_matches_page
    then_i_see_a_not_found_page

    when_the_duplicate_matching_feature_flag_is_active
    and_i_click_the_duplicate_matches_tab
    then_i_should_see_a_message_that_there_are_no_matches

    when_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_fraud_matches_worker_has_run
    and_the_second_fraud_match_is_resolved
    and_i_click_the_duplicate_matches_tab
    then_i_should_see_list_of_under_review_duplicates
    and_i_should_see_a_counter_for_under_review_duplicates

    when_i_click_on_a_the_resolved_link
    then_i_should_see_list_of_resolved_duplicates

    when_i_click_on_a_the_under_review_link
    and_i_click_on_a_duplicate
    then_i_see_the_details_for_each_duplicate_candidate

    when_i_click_on_resolve
    then_the_duplicate_match_is_resolved
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_the_duplicate_matching_feature_flag_is_inactive
    FeatureFlag.deactivate(:duplicate_matching)
  end

  def when_the_duplicate_matching_feature_flag_is_active
    FeatureFlag.activate(:duplicate_matching)
  end

  def then_i_should_see_a_message_that_there_are_no_matches
    expect(page).to have_content 'There are currently no duplicate applications'
  end

  def when_there_are_candidates_with_duplicate_applications_in_the_system
    @bob = create(:candidate, email_address: 'bob@example.com')
    @robert = create(:candidate, email_address: 'robert@example.com')
    @alice = create(:candidate, email_address: 'alice@example.com')
    @ali = create(:candidate, email_address: 'ali@example.com')

    @bobs_application_form = create(:application_form, candidate: @bob, first_name: 'Bob', last_name: 'Roberts', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: 7.days.ago)
    @roberts_application_form = create(:application_form, candidate: @robert, first_name: 'Robert', last_name: 'Roberts', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
    @alices_application_form = create(:application_form, candidate: @alice, first_name: 'Alice', last_name: 'Roberts', date_of_birth: '1999-10-12', postcode: 'W3 6ET', submitted_at: 10.days.ago)
    @alis_application_form = create(:application_form, candidate: @ali, first_name: 'Ali', last_name: 'Roberts', date_of_birth: '1999-10-12', postcode: 'W3 6ET')
  end

  def and_the_update_fraud_matches_worker_has_run
    UpdateFraudMatchesWorker.perform_async
  end

  def and_the_second_fraud_match_is_resolved
    @ali.reload.fraud_match.update!(resolved: true)
  end

  def and_i_go_to_duplicate_matches_page
    visit support_interface_duplicate_matches_path
  end

  def and_i_click_the_duplicate_matches_tab
    click_link 'Candidates'
    click_link 'Duplicate candidate matches'
  end

  def then_i_see_a_not_found_page
    expect(page).to have_content 'Page not found'
  end

  def then_i_should_see_list_of_under_review_duplicates
    expect(page).to have_content('2 candidates with postcode W6 9BH and DOB 8 Aug 1998')
    expect(page).not_to have_link('2 candidates with postcode W3 6ET')
  end

  def and_i_should_see_a_counter_for_under_review_duplicates
    within('span[class=app-count]') do
      expect(page).to have_content('1')
    end
  end

  def when_i_click_on_a_the_resolved_link
    click_link 'Resolved'
  end

  def then_i_should_see_list_of_resolved_duplicates
    expect(page).to have_content('2 candidates with postcode W3 6ET and DOB 12 Oct 1999')
    expect(page).not_to have_link('2 candidates with postcode W6 9BH')
  end

  def when_i_click_on_a_the_under_review_link
    click_link 'Under review'
  end

  def and_i_click_on_a_duplicate
    click_link '2 candidates with postcode W6 9BH and DOB 8 Aug 1998'
  end

  def then_i_see_the_details_for_each_duplicate_candidate
    expect(page).to have_content('2 candidates with postcode W6 9BH and DOB 8 Aug 1998')
    expect(page).to have_button('Mark as resolved')
  end

  def when_i_click_on_resolve
    click_button 'Mark as resolved'
  end

  def then_the_duplicate_match_is_resolved
    expect(@bob.reload.fraud_match.resolved).to be(true)
    expect(page).to have_button('Mark as unresolved')
  end
end