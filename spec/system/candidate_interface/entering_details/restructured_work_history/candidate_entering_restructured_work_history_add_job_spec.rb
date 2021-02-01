require 'rails_helper'

RSpec.feature 'Candidate submits restructured work history' do
  include CandidateHelper

  scenario 'Candidate adds job details' do
    FeatureFlag.activate(:restructured_work_history)

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_the_start_page

    when_i_choose_that_i_have_work_history_to_add
    then_i_should_see_the_add_a_job_page

    when_i_fill_in_the_job_form_with_incorrect_date_fields
    then_i_should_see_date_validation_errors
    and_i_should_see_the_incorrect_date_values

    when_i_fill_in_the_job_form_with_valid_details
    then_i_should_see_the_work_history_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_work_history
    click_link t('page_titles.work_history')
  end

  def then_i_should_see_the_start_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_path
  end

  def when_i_choose_that_i_have_work_history_to_add
    choose 'Yes'
    click_button 'Continue'
  end

  def then_i_should_see_the_add_a_job_page
    expect(page).to have_current_path candidate_interface_new_restructured_work_history_path
  end

  def when_i_fill_in_the_job_form_with_incorrect_date_fields
    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '33'
    end

    click_button t('save_and_continue')
  end

  def then_i_should_see_date_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.start_date.invalid')
  end

  def and_i_should_see_the_incorrect_date_values
    within('[data-qa="start-date"]') do
      expect(find_field('Month').value).to eq('33')
    end
  end

  def when_i_fill_in_the_job_form_with_valid_details
    scope = 'application_form.restructured_work_history'
    fill_in t('employer.label', scope: scope), with: 'Weyland-Yutani'
    fill_in t('role.label', scope: scope), with: 'Chief Terraforming Officer'

    choose 'Part time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '5'
      fill_in 'Year', with: '2014'
    end

    within('[data-qa="currently-working"]') do
      choose 'No'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '1'
      fill_in 'Year', with: '2019'
    end

    within('[data-qa="relevant-skills"]') do
      choose 'Yes'
    end

    click_button t('save_and_continue')
  end

  def then_i_should_see_the_work_history_review_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_review_path
  end

  def and_i_click_on_continue
    click_button t('save_and_continue')
  end
end
