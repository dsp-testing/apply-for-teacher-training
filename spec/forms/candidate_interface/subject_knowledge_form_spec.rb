require 'rails_helper'

RSpec.describe CandidateInterface::SubjectKnowledgeForm, type: :model do
  let(:data) do
    {
      subject_knowledge: Faker::Lorem.paragraph_by_chars(number: 200),
    }
  end

  let(:form_data) do
    {
      subject_knowledge: data[:subject_knowledge],
    }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      subject_knowledge = described_class.build_from_application(
        application_form,
      )

      expect(subject_knowledge).to have_attributes(form_data)
    end
  end

  describe '#blank?' do
    it 'is blank when containing only whitespace' do
      application_form = described_class.new(subject_knowledge: ' ')
      expect(application_form).to be_blank
    end

    it 'is not blank when containing some text' do
      application_form = described_class.new(subject_knowledge: 'Test')
      expect(application_form).not_to be_blank
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      subject_knowledge = described_class.new

      expect(subject_knowledge.save(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      subject_knowledge = described_class.new(form_data)

      expect(subject_knowledge.save(application_form)).to be(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe 'validations' do
    it { is_expected.not_to validate_presence_of(:subject_knowledge) }

    valid_text = Faker::Lorem.sentence(word_count: 400)
    invalid_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(valid_text).for(:subject_knowledge) }
    it { is_expected.not_to allow_value(invalid_text).for(:subject_knowledge) }
  end
end
