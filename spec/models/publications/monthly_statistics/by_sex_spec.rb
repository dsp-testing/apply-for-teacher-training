require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::BySex do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course age group'" do
    5.times do
      create_application_choice(
        statuses: %i[with_rejection with_rejection],
        sex: 'female',
      )
      create_application_choice(
        statuses: %i[awaiting_provider_decision],
        sex: 'Prefer not to say',
      )
      create_application_choice(
        statuses: %i[awaiting_provider_decision with_rejection with_recruited],
        sex: 'Prefer not to say',
      )
      create_application_choice(
        statuses: %i[awaiting_provider_decision with_rejection with_offer],
        sex: 'intersex',
      )
      create_application_choice(
        statuses: %i[with_deferred_offer],
        sex: 'male',
        status_before_deferral: 'offer',
        recruitment_cycle_year: RecruitmentCycle.previous_year,
      )
      create_application_choice(
        statuses: %i[with_deferred_offer],
        sex: 'female',
        status_before_deferral: 'offer',
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      create_application_choice(
        statuses: %i[with_conditions_not_met],
        sex: 'intersex',
      )
      create_application_choice(
        statuses: %i[with_offer],
        sex: 'female',
      )
      create_application_choice(
        statuses: %i[with_withdrawn_offer],
        sex: 'female',
      )
      create_application_choice(
        statuses: %i[withdrawn],
        sex: 'male',
      )
      create_application_choice_with_previous_application(
        status: :with_rejection,
        sex: 'male',
      )
    end

    expect(statistics).to eq(
      { rows:
        [
          {
            'Sex' => 'Female',
            'Recruited' => '0 to 4',
            'Conditions pending' => '0 to 4',
            'Received an offer' => 5,
            'Awaiting provider decisions' => '0 to 4',
            'Unsuccessful' => 10,
            'Total' => 15,
          },
          {
            'Sex' => 'Male',
            'Recruited' => '0 to 4',
            'Conditions pending' => '0 to 4',
            'Received an offer' => 5,
            'Awaiting provider decisions' => '0 to 4',
            'Unsuccessful' => 10,
            'Total' => 15,
          },
          {
            'Sex' => 'Intersex',
            'Recruited' => '0 to 4',
            'Conditions pending' => '0 to 4',
            'Received an offer' => 5,
            'Awaiting provider decisions' => '0 to 4',
            'Unsuccessful' => 5,
            'Total' => 10,
          },
          {
            'Sex' => 'Prefer not to say',
            'Recruited' => 5,
            'Conditions pending' => '0 to 4',
            'Received an offer' => '0 to 4',
            'Awaiting provider decisions' => 5,
            'Unsuccessful' => '0 to 4',
            'Total' => 10,
          },
        ],
        column_totals: [5, '0 to 4', 15, 5, 25, 50] },
    )
  end

  def create_application_choice(
    statuses:,
    sex:,
    recruitment_cycle_year: RecruitmentCycle.current_year,
    previous_application_form: nil,
    status_before_deferral: nil
  )
    application_form = create(
      :application_form,
      previous_application_form: previous_application_form,
      recruitment_cycle_year: recruitment_cycle_year,
      equality_and_diversity: { 'sex' => sex },
    )
    statuses.each do |status|
      create(
        :application_choice,
        status,
        application_form: application_form,
        status_before_deferral: status_before_deferral,
      )
    end

    application_form
  end

  def create_application_choice_with_previous_application(
    status:,
    sex:,
    recruitment_cycle_year: RecruitmentCycle.current_year
  )
    previous_application_form = create_application_choice(
      statuses: [status],
      sex: sex,
      recruitment_cycle_year: recruitment_cycle_year,
    )
    create_application_choice(
      statuses: [status],
      sex: sex,
      recruitment_cycle_year: recruitment_cycle_year,
      previous_application_form: previous_application_form,
    )
  end
end