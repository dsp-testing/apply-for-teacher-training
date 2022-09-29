require 'rails_helper'

RSpec.describe GenerateTestApplications, mid_cycle: true do
  it 'generates test candidates with applications in various states', sidekiq: true do
    previous_cycle = RecruitmentCycle.previous_year
    current_cycle = RecruitmentCycle.current_year

    # necessary to test 'cancelled' state
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: 2020))

    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: previous_cycle))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: previous_cycle))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: previous_cycle))

    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: current_cycle))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: current_cycle))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: current_cycle))

    slack_request = stub_request(:post, 'https://example.com')

    ClimateControl.modify(STATE_CHANGE_SLACK_URL: 'https://example.com') do
      described_class.new.perform
    end

    expect(slack_request).not_to have_been_made

    expect(ApplicationChoice.pluck(:status)).to include(
      'unsubmitted',
      'awaiting_provider_decision',
      'offer',
      'rejected',
      'declined',
      'withdrawn',
      'recruited',
    )

    # there is at least one unsubmitted application to a full course
    expect(ApplicationChoice.where(status: 'unsubmitted').map(&:course_option).select(&:no_vacancies?)).not_to be_empty

    # there is at least one successful carried over application
    expect(ApplicationForm.joins(:application_choices).where('application_choices.status': 'offer', phase: 'apply_1').where.not(previous_application_form_id: nil)).not_to be_empty

    # there is at least one successful apply again application
    expect(ApplicationForm.joins(:application_choices).where('application_choices.status': 'offer', phase: 'apply_2').where.not(previous_application_form_id: nil)).not_to be_empty
  end

  it 'generates test applications for the next cycle', sidekiq: true do
    FeatureFlag.activate(:new_references_flow)
    current_cycle = RecruitmentCycle.current_year
    next_cycle = RecruitmentCycle.next_year
    provider = create(:provider)

    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: current_cycle, provider: provider))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: current_cycle, provider: provider))
    create(:course_option, course: create(:course, :open_on_apply, recruitment_cycle_year: current_cycle, provider: provider))

    ClimateControl.modify(STATE_CHANGE_SLACK_URL: 'https://example.com') do
      described_class.new.perform(true)
    end

    pending_references = ApplicationChoice.where(status: :pending_conditions).first.application_form.application_references.flat_map(&:feedback_status)
    processed_references = ApplicationChoice.where(status: :pending_conditions).last.application_form.application_references.flat_map(&:feedback_status)

    expect(ApplicationChoice.pluck(:status)).to include(
      'awaiting_provider_decision',
      'pending_conditions',
      'offer',
      'rejected',
      'offer_withdrawn',
      'offer_deferred',
      'recruited',
    )

    expect(ApplicationForm.last.recruitment_cycle_year).to eq next_cycle
    expect(pending_references).to eq %w[feedback_requested feedback_requested feedback_requested feedback_requested feedback_requested]
    expect(processed_references).to eq %w[feedback_refused cancelled feedback_provided feedback_provided feedback_provided]
  end
end
