module MonthlyStatisticsTestHelper
  def generate_monthly_statistics_test_data
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    form = create(:application_form, date_of_birth: date_of_birth(years_ago: 20), candidate: hidden_candidate)
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(level: 'primary', program_type: 'higher_education_programme', region: 'eastern', subjects: [primary_subject(:mathematics)]),
           application_form: form)

    # Apply 1
    form = create(:application_form, date_of_birth: date_of_birth(years_ago: 20), phase: 'apply_1')
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(level: 'primary', program_type: 'school_direct_training_programme', region: 'eastern', subjects: [primary_subject(:mathematics)]),
           application_form: form)

    form = create(:application_form,  date_of_birth: date_of_birth(years_ago: 23), phase: 'apply_1')
    create(:application_choice,
           :with_accepted_offer,
           course_option: course_option_with(level: 'primary', program_type: 'school_direct_salaried_training_programme', region: 'east_midlands', subjects: [primary_subject(:english)]),
           application_form: form)

    form = create(:application_form, date_of_birth: date_of_birth(years_ago: 24), phase: 'apply_1')
    create(:application_choice,
           :with_offer,
           course_option: course_option_with(level: 'primary', program_type: 'pg_teaching_apprenticeship', region: 'london', subjects: [primary_subject(:geography_and_history)]),
           application_form: form)

    form = create(:application_form, date_of_birth: date_of_birth(years_ago: 26), phase: 'apply_1')
    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_with(level: 'primary', program_type: 'scitt_programme', region: 'north_east', subjects: [primary_subject(:no_specialism)]),
           application_form: form)

    form = create(:application_form, date_of_birth: date_of_birth(years_ago: 31), phase: 'apply_1')
    create(:application_choice,
           :with_declined_offer,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'north_west', subjects: [create(:subject, name: 'Art and design', code: 'W1'), create(:subject, name: 'History', code: 'V1')]),
           application_form: form)

    form = create(:application_form, date_of_birth: date_of_birth(years_ago: 35), phase: 'apply_1')
    create(:application_choice,
           :withdrawn,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'south_east'),
           application_form: form)

    rejected_form = create(:application_form, date_of_birth: date_of_birth(years_ago: 40), phase: 'apply_1')
    create(:application_choice,
           :with_rejection,
           course_option: course_option_with(level: 'further_education', program_type: 'higher_education_programme', region: 'south_west'),
           application_form: rejected_form)

    form = create(:application_form, date_of_birth: date_of_birth(years_ago: 66), phase: 'apply_1')
    create(:application_choice,
           :with_deferred_offer,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'west_midlands'),
           application_form: form)

    # Apply 2
    form = DuplicateApplication.new(rejected_form, target_phase: 'apply_2').duplicate
    form.update(submitted_at: Time.zone.now)
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'yorkshire_and_the_humber'),
           application_form: form)
  end

  def course_option_with(
    program_type:,
    region:,
    level:,
    subjects: []
  )
    create(:course_option,
           course: create(:course,
                          program_type: program_type,
                          level: level,
                          subjects: subjects,
                          provider: create(:provider,
                                           region_code: region)))
  end

  def primary_subject(specialism)
    name, code = {
      no_specialism: %w[Primary 00],
      english: ['Primary with English', '01'],
      geography_and_history: ['Primary with geography and history', '02'],
      mathematics: ['Primary with mathematics', '03'],
      modern_languages: ['Primary with modern languages', '04'],
      pe: ['Primary with physical education', '06'],
      science: ['Primary with science', '07'],
    }[specialism]

    Subject.find_by(name: name, code: code).presence || create(:subject, name: name, code: code)
  end

  def expect_report_rows(column_headings:)
    expected_rows = yield.map { |row| column_headings.zip(row).to_h } # [['Status', 'Recruited'], ['First Application', 1] ...].to_h
    expect(statistics[:rows]).to match_array expected_rows
  end

  def expect_column_totals(*totals)
    expect(statistics[:column_totals]).to eq totals
  end

  def date_of_birth(years_ago:)
    # go back an extra year because we calculate d.o.b. backwards from 1 August
    if Time.zone.today > Date.parse('1st August')
      years_ago.years.ago
    else
      (years_ago + 1).years.ago
    end
  end
end
