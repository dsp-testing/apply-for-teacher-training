require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationsLeftMessageComponent, continuous_applications: true do
  let(:application_form) { create(:application_form) }

  subject(:message) do
    render_inline(described_class.new(application_form)).text
  end

  context 'when unsubmitted' do
    it 'returns default message' do
      expect(message).to include('You can add up to 4 applications at a time.')
    end
  end

  context 'when submitted' do
    let(:application_form) { create(:application_form, :submitted) }

    context 'when some applications are submitted and some unsuccessfull' do
      it 'returns message of how many more can be added' do
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :rejected, application_form:)
        create(:application_choice, :inactive, application_form:)
        expect(message).to include('You can add 2 more applications.')
      end
    end

    context 'when at least 4 applications are submitted and waiting' do
      it 'returns message that is not possible to add more' do
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :rejected, application_form:)
        create(:application_choice, :inactive, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        expect(message).to include('You cannot add any more applications because you’re waiting for decisions on 4 others.')
        expect(message).to include('If one of your applications is unsuccessful, or you withdraw it, you will be able to add another application.')
      end
    end
  end
end