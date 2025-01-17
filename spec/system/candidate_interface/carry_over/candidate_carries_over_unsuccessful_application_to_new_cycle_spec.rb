require 'rails_helper'

RSpec.describe 'Candidate can carry over unsuccessful application to a new recruitment cycle after the apply 2 deadline' do
  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR))
  end

  scenario 'when an unsuccessful candidate returns in the next recruitment cycle they can re-apply by carrying over their original application' do
    given_i_am_signed_in
    and_i_have_an_application_with_a_rejection

    when_the_apply2_deadline_passes
    and_i_visit_my_application_complete_page
    then_i_see_the_carry_over_inset_text

    when_i_click_apply_again
    then_i_can_see_application_details
    and_i_can_see_that_no_courses_are_selected_and_i_cannot_add_any_yet

    when_the_next_cycle_opens
    and_i_visit_my_application_complete_page
    then_i_can_add_course_choices
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_application_with_a_rejection
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create(:application_choice, :rejected, application_form: @application_form)
  end

  def when_the_apply2_deadline_passes
    advance_time_to(after_apply_2_deadline)
  end

  def and_i_visit_my_application_complete_page
    logout
    login_as(@candidate)
    visit candidate_interface_application_complete_path
  end

  def and_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_see_the_carry_over_inset_text
    next_recruitment_year_range = CycleTimetable.cycle_year_range(CycleTimetable.next_year)
    expect(page).to have_content "You can apply for courses starting in the #{next_recruitment_year_range} academic year instead."
  end

  def when_i_click_apply_again
    click_button 'Apply again'
  end

  def then_i_can_see_application_details
    expect(page).to have_content('Personal information Completed')
    click_link 'Personal information'
    expect(page).to have_content(@application_form.full_name)
    click_button t('continue')
  end

  def and_i_can_see_that_no_courses_are_selected_and_i_cannot_add_any_yet
    expect(page).to have_content "You can find courses from 9am on #{CycleTimetable.find_reopens.to_fs(:govuk_date)}. You can keep making changes to your application until then."
    expect(page).not_to have_link 'Course choice'
  end

  def when_the_next_cycle_opens
    advance_time_to(after_apply_reopens)
  end

  def then_i_can_add_course_choices
    expect(page).to have_content('Choose your courses Incomplete')
    expect(page).to have_content 'You can apply for up to 4 courses'
    click_link 'Choose your courses'
  end
end
