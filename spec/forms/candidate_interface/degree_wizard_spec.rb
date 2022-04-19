require 'rails_helper'

RSpec.describe CandidateInterface::DegreeWizard do
  subject(:wizard) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  describe '#next_step' do
    context 'country step' do
      context 'when country is uk' do
        let(:degree_params) { { uk_or_non_uk: 'uk', current_step: :country } }

        it 'redirects to degree type step' do
          expect(wizard.next_step).to be(:degree_level)
        end
      end

      context 'when country is not the uk and country is present' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', country: 'FR', current_step: :country } }

        it 'redirects to the subject step' do
          expect(wizard.next_step).to be(:subject)
        end
      end

      context 'when country is not the uk and country is nil' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :country } }

        it 'raises an InvalidStepError' do
          expect { wizard.next_step }.to raise_error(CandidateInterface::DegreeWizard::InvalidStepError)
        end
      end
    end

    context 'level step' do
      let(:degree_params) { { current_step: :degree_level } }

      it 'redirects to the subject page' do
        expect(wizard.next_step).to be(:subject)
      end
    end

    describe 'subject step' do
      context 'when uk degree and level 6 diploma' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: 'uk', degree_level: 'Level 6 Diploma' } }

        it 'redirects to the university page' do
          expect(wizard.next_step).to be(:university)
        end
      end

      context 'when uk degree and another qualification selected' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: 'uk', degree_level: 'Another qualification equivalent to a degree' } }

        it 'redirects to the university page' do
          expect(wizard.next_step).to be(:university)
        end
      end

      context 'when either uk or non_uk degree and any other degree_level' do
        let(:degree_params) { { current_step: :subject, uk_or_non_uk: %w[uk non_uk].sample } }

        it 'redirects to the type page' do
          expect(wizard.next_step).to be(:type)
        end
      end
    end

    context 'type step' do
      let(:degree_params) { { current_step: :type } }

      it 'redirects to university page' do
        expect(wizard.next_step).to be(:university)
      end
    end

    context 'university step' do
      let(:degree_params) { { current_step: :university } }

      it 'redirects to completed page' do
        expect(wizard.next_step).to be(:completed)
      end
    end

    context 'completed step' do
      let(:degree_params) { { current_step: :completed } }

      it 'redirects to the grades page' do
        expect(wizard.next_step).to be(:grade)
      end
    end

    context 'grade step' do
      let(:degree_params) { { current_step: :grade } }

      it 'redirects to the start years page' do
        expect(wizard.next_step).to be(:start_year)
      end
    end

    context 'start year step' do
      let(:degree_params) { { current_step: :start_year } }

      it 'redirects to the graduation years page' do
        expect(wizard.next_step).to be(:award_year)
      end
    end

    describe 'graduation year step' do
      context 'uk degree' do
        let(:degree_params) { { uk_or_non_uk: 'uk', current_step: :award_year } }

        it 'redirects to the graduation years page' do
          expect(wizard.next_step).to be(:review)
        end
      end

      context 'non_uk degree and completed' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :award_year, completed: 'Yes' } }

        it 'redirects to the enic page' do
          expect(wizard.next_step).to be(:enic)
        end
      end

      context 'non_uk degree and not completed' do
        let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :award_year, completed: 'No' } }

        it 'redirects to the review page' do
          expect(wizard.next_step).to be(:review)
        end
      end
    end

    context 'enic step' do
      let(:degree_params) { { uk_or_non_uk: 'non_uk', current_step: :enic } }

      it 'redirects to the review page' do
        expect(wizard.next_step).to be(:review)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:uk_or_non_uk).on(:country) }
    it { is_expected.to validate_presence_of(:subject).on(:subject) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255).on(:subject) }
    it { is_expected.to validate_presence_of(:university).on(:university) }
    it { is_expected.to validate_presence_of(:completed).on(:completed) }
    it { is_expected.to validate_presence_of(:start_year).on(:start_year) }
    it { is_expected.to validate_presence_of(:award_year).on(:award_year) }

    context 'Non-UK validations' do
      let(:degree_params) { { uk_or_non_uk: 'non_uk', grade: 'Yes', have_enic_reference: 'Yes' } }

      it { is_expected.to validate_presence_of(:country).on(:country) }
      it { is_expected.to validate_presence_of(:international_type).on(:type) }
      it { is_expected.to validate_presence_of(:other_grade).on(:grade) }
      it { is_expected.to validate_length_of(:other_grade).is_at_most(255).on(:grade) }
      it { is_expected.to validate_presence_of(:have_enic_reference).on(:enic) }
      it { is_expected.to validate_presence_of(:enic_reference).on(:enic) }
      it { is_expected.to validate_presence_of(:comparable_uk_degree).on(:enic) }
    end

    context 'UK validations' do
      let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: 'Another qualification equivalent to a degree', grade: 'Other' } }

      it { is_expected.to validate_presence_of(:degree_level).on(:degree_level) }
      it { is_expected.to validate_presence_of(:equivalent_level).on(:degree_level) }
      it { is_expected.to validate_presence_of(:grade).on(:grade) }
      it { is_expected.to validate_presence_of(:other_grade).on(:grade) }
      it { is_expected.to validate_length_of(:other_grade).is_at_most(255).on(:grade) }
      it { is_expected.to validate_presence_of(:type).on(:type) }
    end

    context 'other type' do
      let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: 'Bachelor degree', type: 'Another bachelor degree type' } }

      it { is_expected.to validate_presence_of(:other_type).on(:type) }
      it { is_expected.to validate_length_of(:other_type).is_at_most(255).on(:type) }
    end

    context 'award year is before start year' do
      let(:degree_params) { { uk_or_non_uk: 'uk', start_year: RecruitmentCycle.current_year, award_year: RecruitmentCycle.previous_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)
        expect(wizard.errors.full_messages).to eq(['Award year Enter a graduation year after your start year'])
      end
    end

    context 'start year is after graduation year' do
      let(:degree_params) { { uk_or_non_uk: 'uk', start_year: RecruitmentCycle.current_year, award_year: RecruitmentCycle.previous_year } }

      it 'is invalid' do
        wizard.valid?(:start_year)
        expect(wizard.errors.full_messages).to eq(['Start year Enter a start year before your graduation year'])
      end
    end

    context 'start year cannot be in future when degree completed' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'Yes', start_year: RecruitmentCycle.next_year } }

      it 'is invalid' do
        wizard.valid?(:start_year)

        expect(wizard.errors.full_messages).to eq(['Start year Enter a start year in the past'])
      end
    end

    context 'award year cannot be in future when degree completed' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'Yes', award_year: RecruitmentCycle.next_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)

        expect(wizard.errors.full_messages).to eq(['Award year Enter an award year in the past'])
      end
    end

    context 'award year cannot be in the past when degree is incomplete' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'No', start_year: RecruitmentCycle.previous_year - 1, award_year: RecruitmentCycle.previous_year, recruitment_cycle_year: RecruitmentCycle.current_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)

        expect(wizard.errors.full_messages).to eq(['Award year Enter a year that is the current year or a year in the future'])
      end
    end

    context 'award year cannot be after end of current cycle if degree incomplete' do
      let(:degree_params) { { uk_or_non_uk: 'uk', completed: 'No', start_year: RecruitmentCycle.previous_year, award_year: RecruitmentCycle.next_year, recruitment_cycle_year: RecruitmentCycle.current_year } }

      it 'is invalid' do
        wizard.valid?(:award_year)

        expect(wizard.errors.full_messages).to eq(['Award year The date you graduate must be before the start of your teacher training'])
      end
    end
  end

  describe 'attributes for persistence' do
    context 'uk' do
      let(:wizard_attrs) do
        {
          application_form_id: 2,
          uk_or_non_uk: 'uk',
          subject: 'History',
          degree_level: 'Bachelor degree',
          type: 'Bachelor of Arts',
          university: 'The University of Cambridge',
          grade: 'First-class honours',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists the correct attributes' do
        expect(wizard.attributes_for_persistence).to eq(
          {
            application_form_id: 2,
            level: 'degree',
            international: false,
            qualification_type: 'Bachelor of Arts',
            qualification_type_hesa_code: '51',
            institution_name: 'The University of Cambridge',
            institution_hesa_code: '114',
            subject: 'History',
            subject_hesa_code: '100302',
            grade: 'First-class honours',
            grade_hesa_code: '1',
            predicted_grade: false,
            start_year: '2000',
            award_year: '2004',
            enic_reference: nil,
            comparable_uk_degree: nil,
          },
        )
      end
    end

    context 'international' do
      let(:wizard_attrs) do
        {
          application_form_id: 1,
          uk_or_non_uk: 'non_uk',
          subject: 'History',
          international_type: 'Diplôme',
          university: 'Aix-Marseille University',
          country: 'FR',
          other_grade: '94%',
          completed: 'Yes',
          start_year: '2000',
          award_year: '2004',
          enic_reference: '4000228364',
          comparable_uk_degree: 'Bachelor (Honours) degree',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists the correct attributes' do
        expect(wizard.attributes_for_persistence).to eq(
          {
            application_form_id: 1,
            international: true,
            level: 'degree',
            qualification_type: 'Diplôme',
            institution_name: 'Aix-Marseille University',
            institution_country: 'FR',
            subject: 'History',
            predicted_grade: false,
            grade: '94%',
            start_year: '2000',
            award_year: '2004',
            enic_reference: '4000228364',
            comparable_uk_degree: 'Bachelor (Honours) degree',
          },
        )
      end
    end

    context 'further uk attributes' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          equivalent_level: 'Equivalent Degree',
          other_grade: 'Distinction',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists value to correct database field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            qualification_type: 'Equivalent Degree',
            qualification_type_hesa_code: nil,
            grade: 'Distinction',
            grade_hesa_code: '12',
          },
        )
      end
    end

    context 'other type and equivalent level are present' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'uk',
          equivalent_level: 'Equivalent Degree',
          other_type: 'Doctor of Science (DSc)',
        }
      end

      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists equivalent level to qualification type field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            qualification_type: 'Equivalent Degree',
          },
        )
      end
    end

    context 'international degree has no grade' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'non_uk',
          grade: 'No',
        }
      end
      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists value to correct database field' do
        expect(wizard.attributes_for_persistence).to include(
          {
            grade: 'N/A',
          },
        )
      end
    end

    context 'international degree is not completed' do
      let(:wizard_attrs) do
        {
          uk_or_non_uk: 'non_uk',
          completed: 'No',
          comparable_uk_degree: 'Bachelor (Ordinary) degree',
          enic_reference: '400001234805',
        }
      end
      let(:wizard) { described_class.new(store, wizard_attrs) }

      it 'persists nil value for comparable uk degree and enic reference' do
        expect(wizard.attributes_for_persistence).to include(
          {
            predicted_grade: true,
            comparable_uk_degree: nil,
            enic_reference: nil,
          },
        )
      end
    end
  end

  describe '#sanitize_attrs' do
    let(:stored_data) { { uk_or_non_uk: 'uk', completed: 'Yes', grade: 'First-class honours' }.to_json }
    let(:attrs) { { uk_or_non_uk: 'non_uk', current_step: :country } }

    before do
      allow(store).to receive(:read).and_return(stored_data)
    end

    describe '#sanitize_uk_or_non_uk' do
      it 'clears the specified attributes' do
        wizard = described_class.new(store, attrs)
        expect(wizard.completed).to be_nil
        expect(wizard.grade).to be_nil
      end
    end

    describe '#sanitize_country' do
      let(:stored_data) { {}.to_json }
      let(:attrs) { { uk_or_non_uk: 'uk', country: 'FR', current_step: :country } }

      it 'clears country' do
        wizard = described_class.new(store, attrs)
        expect(wizard.country).to be_nil
        expect(wizard.uk_or_non_uk).to eq 'uk'
      end

      it 'does not clear country if another country selected' do
        new_attrs = attrs.merge(uk_or_non_uk: 'Another country')
        wizard = described_class.new(store, new_attrs)
        expect(wizard.country).to eq 'FR'
        expect(wizard.uk_or_non_uk).to eq 'Another country'
      end
    end

    context 'sanitize_grade' do
      let(:stored_data) { {}.to_json }
      let(:attrs) { { grade: 'First-class honours', other_grade: '94%', current_step: :grade } }

      it 'clears other grade' do
        wizard = described_class.new(store, attrs)
        expect(wizard.grade).to eq 'First-class honours'
        expect(wizard.other_grade).to be_nil
      end

      it 'does not clear other grade if other selected' do
        new_attrs = attrs.merge(grade: 'Other')
        wizard = described_class.new(store, new_attrs)
        expect(wizard.grade).to eq 'Other'
        expect(wizard.other_grade).to eq('94%')
      end
    end

    context 'sanitize_type' do
      let(:stored_data) { { degree_level: 'Bachelor degree' }.to_json }
      let(:attrs) { { type: 'Bachelor of Arts', other_type: 'Bachelor of Technology', current_step: :type } }

      it 'clears other type' do
        wizard = described_class.new(store, attrs)
        expect(wizard.type).to eq 'Bachelor of Arts'
        expect(wizard.other_type).to be_nil
      end

      it 'does not clear other type if another type selected' do
        new_attrs = attrs.merge(type: 'Another bachelor degree type')
        wizard = described_class.new(store, new_attrs)
        expect(wizard.type).to eq 'Another bachelor degree type'
        expect(wizard.other_type).to eq('Bachelor of Technology')
      end
    end

    context 'sanitize_degree_level' do
      let(:stored_data) { {}.to_json }
      let(:attrs) { { degree_level: 'Bachelor', equivalent_level: 'Diploma', current_step: :degree_level } }

      it 'clears the equivalent level' do
        wizard = described_class.new(store, attrs)
        expect(wizard.degree_level).to eq 'Bachelor'
        expect(wizard.equivalent_level).to be_nil
      end

      it 'does not clear equivalent level if another qualification selected' do
        new_attrs = attrs.merge(degree_level: 'Another qualification equivalent to a degree')
        wizard = described_class.new(store, new_attrs)
        expect(wizard.degree_level).to eq 'Another qualification equivalent to a degree'
        expect(wizard.equivalent_level).to eq 'Diploma'
      end
    end

    context 'sanitize_enic' do
      let(:stored_data) { {}.to_json }
      let(:attrs) { { have_enic_reference: 'No', enic_reference: '40008234', comparable_uk_degree: 'Bachelor (Ordinary) degree', current_step: :enic } }

      it 'clears the enic number and comparable uk degree' do
        wizard = described_class.new(store, attrs)
        expect(wizard.enic_reference).to be_nil
        expect(wizard.comparable_uk_degree).to be_nil
      end

      it 'does not clear the enic number and comparable uk degree if yes selected' do
        new_attrs = attrs.merge(have_enic_reference: 'Yes')
        wizard = described_class.new(store, new_attrs)
        expect(wizard.enic_reference).to eq '40008234'
        expect(wizard.comparable_uk_degree).to eq 'Bachelor (Ordinary) degree'
      end
    end
  end

  describe '#from_application_qualification' do
    let(:wizard) do
      described_class.from_application_qualification(store, application_qualification)
    end

    describe 'uk degree' do
      let(:application_qualification)  do
        create(:degree_qualification, id: 1, qualification_type: 'Bachelor of Arts', grade: 'First-class honours')
      end

      context 'standard uk degree' do
        it 'rehydrates the degree wizard' do
          stores = {
            id: 1,
            uk_or_non_uk: 'uk',
            application_form_id: application_qualification.application_form.id,
            degree_level: 'Bachelor degree',
            equivalent_level: nil,
            type: application_qualification.qualification_type,
            international_type: nil,
            other_type: nil,
            grade: application_qualification.grade,
            other_grade: nil,
            completed: 'No',
            subject: application_qualification.subject,
            university: application_qualification.institution_name,
            start_year: application_qualification.start_year,
            award_year: application_qualification.award_year,
            have_enic_reference: nil,
            enic_reference: nil,
            comparable_uk_degree: nil,
          }

          expect(wizard.as_json).to include(stores.stringify_keys)
        end
      end

      context 'uk degree with other type' do
        before do
          application_qualification.qualification_type = 'Bachelor of Technology'
        end

        it 'rehydrates the correct attributes' do
          expect(wizard.degree_level).to eq('Bachelor degree')
          expect(wizard.equivalent_level).to be_nil
          expect(wizard.type).to eq('Another bachelor degree type')
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to eq('Bachelor of Technology')
        end
      end

      context 'uk degree with equivalent level' do
        before do
          application_qualification.qualification_type = 'A different degree'
        end

        it 'rehydrates the degree wizard' do
          expect(wizard.degree_level).to eq('Another qualification equivalent to a degree')
          expect(wizard.equivalent_level).to eq('A different degree')
          expect(wizard.type).to be_nil
          expect(wizard.international_type).to be_nil
          expect(wizard.other_type).to be_nil
        end
      end
    end

    describe 'non-uk degree' do
      let(:application_qualification) do
        create(:non_uk_degree_qualification, id: 1)
      end

      context 'standard non uk degree' do
        it 'rehydrates the degree wizard' do
          stores = {
            id: 1,
            uk_or_non_uk: 'non_uk',
            country: application_qualification.institution_country,
            application_form_id: application_qualification.application_form.id,
            degree_level: nil,
            equivalent_level: nil,
            type: nil,
            international_type: application_qualification.qualification_type,
            other_type: nil,
            grade: 'Yes',
            other_grade: application_qualification.grade,
            completed: 'Yes',
            subject: application_qualification.subject,
            university: application_qualification.institution_name,
            start_year: application_qualification.start_year,
            award_year: application_qualification.award_year,
            have_enic_reference: 'Yes',
            enic_reference: application_qualification.enic_reference,
            comparable_uk_degree: application_qualification.comparable_uk_degree,
          }

          expect(wizard.as_json).to include(stores.stringify_keys)
        end
      end

      context 'non-uk degree without enic reference or comparable uk degree' do
        before do
          application_qualification.enic_reference = nil
          application_qualification.comparable_uk_degree = nil
        end

        it 'rehydrates the correct attributes' do
          expect(wizard.have_enic_reference).to eq('No')
          expect(wizard.enic_reference).to be_nil
          expect(wizard.comparable_uk_degree).to be_nil
        end
      end
    end
  end

  describe '#persist' do
    let(:application_form) { create(:application_form) }
    let!(:application_qualification) { create(:degree_qualification, award_year: '2014') }
    let(:degree_params) { { id: application_qualification.id, award_year: '2011', application_form_id: application_form.id } }

    before do
      allow(store).to receive(:delete)
    end

    context 'updates degree if it exists' do
      it 'attribute is changed' do
        expect { wizard.persist! }.not_to(change { ApplicationQualification.count })
        application_qualification.reload
        expect(application_qualification.award_year).to eq('2011')
      end
    end

    context 'creates new degree if it does not exist' do
      let(:degree_params) { { id: nil, award_year: '2011', application_form_id: application_form.id } }

      it 'creates new degree entry' do
        expect { wizard.persist! }.to change { ApplicationQualification.count }.from(1).to(2)
      end
    end
  end
end