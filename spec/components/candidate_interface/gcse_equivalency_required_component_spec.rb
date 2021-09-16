require 'rails_helper'

RSpec.describe CandidateInterface::GcseEquivalencyRequiredComponent, type: :component do
  let(:application_form) { create(:application_form) }

  let(:course_option1) { create(:course_option, course: create(:course, :open_on_apply, accept_gcse_equivalency: true, accept_english_gcse_equivalency: true, accept_maths_gcse_equivalency: true, accept_science_gcse_equivalency: true)) }
  let(:course_option2) { create(:course_option, course: create(:course, :open_on_apply, accept_gcse_equivalency: false)) }

  let(:application_choice1) do
    build_stubbed(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option1,
      application_form: application_form,
    )
  end

  let(:application_choice2) do
    build_stubbed(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option2,
      application_form: application_form,
    )
  end

  context 'course accepts gcse equivalencies' do
    it 'renders the correct gcse row content without guidance' do
      result = render_inline(described_class.new(application_choice1))
      expect(result.text).to include('This provider will accept equivalency tests in English, maths and science')
    end
  end

  context 'application has no missing gcses and course does not accept gcse equivalencies' do
    it 'renders the correct gcse row content without guidance' do
      result = render_inline(described_class.new(application_choice2))
      expect(result.text).to include('This provider will not accept equivalency tests')
    end
  end

  context 'application has missing gcse(s) and equivalencies are not accepted' do
    context 'application has one missing gcse and course does not accept them' do
      it 'renders the gcse row with guidance' do
        create(
          :gcse_qualification,
          subject: 'english',
          qualification_type: 'missing',
          currently_completing_qualification: false,
          application_form: application_form,
        )

        result = render_inline(described_class.new(application_choice2))
        expect(result.text).to include('You said you do not have a qualification in English')
      end
    end

    context 'application has two pending gcses and course does not accept them' do
      it 'renders the degree row with guidance' do
        create(
          :gcse_qualification,
          subject: 'english',
          qualification_type: 'missing',
          currently_completing_qualification: false,
          application_form: application_form,
        )

        create(
          :gcse_qualification,
          subject: 'maths',
          qualification_type: 'missing',
          currently_completing_qualification: false,
          application_form: application_form,
        )

        result = render_inline(described_class.new(application_choice2))
        expect(result.text).to include('You said you do not have a qualification in English and maths')
      end
    end

    context 'application has three pending gcses and course does not accept them' do
      it 'renders the gcse row with guidance' do
        create(
          :gcse_qualification,
          subject: 'english',
          qualification_type: 'missing',
          currently_completing_qualification: false,
          application_form: application_form,
        )
        create(
          :gcse_qualification,
          subject: 'maths',
          qualification_type: 'missing',
          currently_completing_qualification: false,
          application_form: application_form,
        )
        create(
          :gcse_qualification,
          subject: 'science',
          qualification_type: 'missing',
          currently_completing_qualification: false,
          application_form: application_form,
        )

        result = render_inline(described_class.new(application_choice2))
        expect(result.text).to include('You said you do not have a qualification in English, maths and science')
      end
    end
  end
end
