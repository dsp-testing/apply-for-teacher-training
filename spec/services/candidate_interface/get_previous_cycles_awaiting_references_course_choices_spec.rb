require 'rails_helper'

RSpec.describe CandidateInterface::GetPreviousCyclesAwaitingReferencesCourseChoices do
  describe '#call' do
    let!(:course_option_from_last_year) { create(:course_option, :previous_year) }
    let!(:application_choice1) { create(:awaiting_references_application_choice, course_option: course_option_from_last_year) }

    before do
      create(:application_choice, :with_offer)
    end

    context 'between the apply_2_deadline and the new cycle launching' do
      it 'returns application forms in the awaiting reference state' do
        Timecop.travel(EndOfCycleTimetable.apply_2_deadline + 1.day) do
          expect(described_class.call).to eq [application_choice1]
        end
      end
    end

    context 'before the apply2 deadline' do
      it 'returns []' do
        Timecop.travel(EndOfCycleTimetable.apply_2_deadline - 1.day) do
          expect(described_class.call).to eq []
        end
      end
    end

    context 'after the new cycle has launched' do
      it 'returns []' do
        Timecop.travel(EndOfCycleTimetable.next_cycle_opens + 1.day) do
          expect(described_class.call).to eq []
        end
      end
    end
  end
end
