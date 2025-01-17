require 'rails_helper'

RSpec.describe SupportInterface::StructuredReasonsForRejectionExport do
  describe 'documentation' do
    before { create(:application_choice, :with_old_structured_rejection_reasons) }

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns an array of hashes containing structured reasons for rejection data' do
      application_choice_one = create(
        :application_choice,
        :with_old_structured_rejection_reasons,
        rejected_by_default: false,
        reject_by_default_at: nil,
        reject_by_default_feedback_sent_at: nil,
        structured_rejection_reasons: {
          course_full_y_n: 'Yes',
          safeguarding_y_n: 'Yes',
          qualifications_y_n: 'Yes',
          safeguarding_concerns: %w[candidate_disclosed_information vetting_disclosed_information other],
          candidate_behaviour_y_n: 'Yes',
          cannot_sponsor_visa_y_n: 'Yes',
          candidate_behaviour_other: 'behaviour',
          quality_of_application_y_n: 'Yes',
          cannot_sponsor_visa_details: 'local',
          other_advice_or_feedback_y_n: nil,
          performance_at_interview_y_n: 'Yes',
          qualifications_other_details: 'details',
          offered_on_another_course_y_n: 'Yes',
          honesty_and_professionalism_y_n: 'Yes',
          other_advice_or_feedback_details: nil,
          offered_on_another_course_details: 'offered',
          candidate_behaviour_what_to_improve: 'behaviour',
          qualifications_which_qualifications: %w[no_maths_gcse no_english_gcse no_science_gcse no_degree other],
          safeguarding_concerns_other_details: 'd',
          honesty_and_professionalism_concerns: %w[information_false_or_inaccurate plagiarism references other],
          quality_of_application_other_details: 'details',
          interested_in_future_applications_y_n: nil,
          why_are_you_rejecting_this_application: nil,
          performance_at_interview_what_to_improve: 'improve',
          quality_of_application_other_what_to_improve: 'improve',
          candidate_behaviour_what_did_the_candidate_do: %w[didnt_reply_to_interview_offer didnt_attend_interview other],
          honesty_and_professionalism_concerns_other_details: 'details',
          quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge other],
          honesty_and_professionalism_concerns_plagiarism_details: 'no',
          honesty_and_professionalism_concerns_references_details: 'yes',
          quality_of_application_subject_knowledge_what_to_improve: 'subject',
          quality_of_application_personal_statement_what_to_improve: 'statement',
          safeguarding_concerns_vetting_disclosed_information_details: 'd',
          safeguarding_concerns_candidate_disclosed_information_details: 'd',
          honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'yes',
        },
      )

      application_choice_two = create(
        :application_choice,
        :with_old_structured_rejection_reasons,
        rejected_by_default: true,
        reject_by_default_at: Time.zone.local(2021, 7, 7),
        reject_by_default_feedback_sent_at: Time.zone.local(2021, 6, 7),
        structured_rejection_reasons: {
          qualifications_y_n: 'Yes',
          qualifications_other_details: 'Not good',
          qualifications_which_qualifications: %w[no_maths_gcse other],
        },
      )

      create(:application_choice, :with_structured_rejection_reasons)

      expect(described_class.new.data_for_export).to eq(
        [{
          candidate_id: application_choice_one.application_form.candidate.id,
          application_choice_id: application_choice_one.id,
          recruitment_cycle_year: application_choice_one.course.recruitment_cycle_year,
          phase: application_choice_one.application_form.phase,
          level: application_choice_one.course.level,
          provider_code: application_choice_one.provider.code,
          course_code: application_choice_one.course.code,
          rejected_at: application_choice_one.rejected_at.iso8601,
          rejected_by_default: false,
          reject_by_default_at: nil,
          reject_by_default_feedback_sent_at: nil,
          something_you_did: true,
          didn_t_reply_to_our_interview_offer: true,
          didn_t_attend_interview: true,
          something_you_did_other_reason_details: application_choice_one.structured_rejection_reasons['candidate_behaviour_other'],
          candidate_behaviour_what_to_improve: application_choice_one.structured_rejection_reasons['candidate_behaviour_what_to_improve'],
          quality_of_application: true,
          personal_statement: true,
          personal_statement_what_to_improve: application_choice_one.structured_rejection_reasons['quality_of_application_personal_statement_what_to_improve'],
          subject_knowledge: true,
          subject_knowledge_what_to_improve: application_choice_one.structured_rejection_reasons['quality_of_application_subject_knowledge_what_to_improve'],
          quality_of_application_what_to_improve: application_choice_one.structured_rejection_reasons['quality_of_application_other_what_to_improve'],
          quality_of_application_other_reason_details: application_choice_one.structured_rejection_reasons['quality_of_application_other_details'],
          qualifications: true,
          no_maths_gcse_grade_4_c_or_above_or_valid_equivalent: true,
          no_english_gcse_grade_4_c_or_above_or_valid_equivalent: true,
          no_science_gcse_grade_4_c_or_above_or_valid_equivalent_for_primary_applicants: true,
          no_degree: true,
          qualifications_other_reason_details: application_choice_one.structured_rejection_reasons['qualifications_other_details'],
          performance_at_interview: true,
          performance_at_interview_what_to_improve: application_choice_one.structured_rejection_reasons['performance_at_interview_what_to_improve'],
          course_full: true,
          they_offered_you_a_place_on_another_course: true,
          offered_on_another_course_details: application_choice_one.structured_rejection_reasons['offered_on_another_course_details'],
          honesty_and_professionalism: true,
          information_given_on_application_form_false_or_inaccurate: true,
          information_given_on_application_form_false_or_inaccurate_details: application_choice_one.structured_rejection_reasons['honesty_and_professionalism_concerns_information_false_or_inaccurate_details'],
          evidence_of_plagiarism_in_personal_statement_or_elsewhere: true,
          evidence_of_plagiarism_in_personal_statement_or_elsewhere_details: application_choice_one.structured_rejection_reasons['honesty_and_professionalism_concerns_plagiarism_details'],
          references_didn_t_support_application: true,
          references_didn_t_support_application_details: application_choice_one.structured_rejection_reasons['honesty_and_professionalism_concerns_references_details'],
          honesty_and_professionalism_other_reason_details: application_choice_one.structured_rejection_reasons['honesty_and_professionalism_concerns_other_details'],
          safeguarding_issues: true,
          information_disclosed_by_candidate_makes_them_unsuitable_to_work_with_children: true,
          information_disclosed_by_candidate_makes_them_unsuitable_to_work_with_children_details: application_choice_one.structured_rejection_reasons['safeguarding_concerns_candidate_disclosed_information_details'],
          information_revealed_by_our_vetting_process_makes_the_candidate_unsuitable_to_work_with_children: true,
          information_revealed_by_our_vetting_process_makes_the_candidate_unsuitable_to_work_with_children_details: application_choice_one.structured_rejection_reasons['safeguarding_concerns_vetting_disclosed_information_details'],
          safeguarding_issues_other_reason_details: application_choice_one.structured_rejection_reasons['safeguarding_concerns_other_details'],
          visa_application_sponsorship: true,
          cannot_sponsor_visa_details: application_choice_one.structured_rejection_reasons['cannot_sponsor_visa_details'],
          additional_advice: false,
          future_applications: false,
          why_are_you_rejecting_this_application_details: nil,
        },
         {
           candidate_id: application_choice_two.application_form.candidate.id,
           application_choice_id: application_choice_two.id,
           recruitment_cycle_year: application_choice_two.course.recruitment_cycle_year,
           phase: application_choice_two.application_form.phase,
           level: application_choice_two.course.level,
           provider_code: application_choice_two.provider.code,
           course_code: application_choice_two.course.code,
           rejected_at: application_choice_two.rejected_at.iso8601,
           rejected_by_default: true,
           reject_by_default_at: Time.zone.local(2021, 7, 7).iso8601,
           reject_by_default_feedback_sent_at: Time.zone.local(2021, 6, 7).iso8601,
           something_you_did: false,
           didn_t_reply_to_our_interview_offer: false,
           didn_t_attend_interview: false,
           something_you_did_other_reason_details: nil,
           candidate_behaviour_what_to_improve: nil,
           quality_of_application: false,
           personal_statement: false,
           personal_statement_what_to_improve: nil,
           subject_knowledge: false,
           subject_knowledge_what_to_improve: nil,
           quality_of_application_what_to_improve: nil,
           quality_of_application_other_reason_details: nil,
           qualifications: true,
           no_maths_gcse_grade_4_c_or_above_or_valid_equivalent: true,
           no_english_gcse_grade_4_c_or_above_or_valid_equivalent: false,
           no_science_gcse_grade_4_c_or_above_or_valid_equivalent_for_primary_applicants: false,
           no_degree: false,
           qualifications_other_reason_details: application_choice_two.structured_rejection_reasons['qualifications_other_details'],
           performance_at_interview: false,
           performance_at_interview_what_to_improve: nil,
           course_full: false,
           they_offered_you_a_place_on_another_course: false,
           offered_on_another_course_details: nil,
           honesty_and_professionalism: false,
           information_given_on_application_form_false_or_inaccurate: false,
           information_given_on_application_form_false_or_inaccurate_details: nil,
           evidence_of_plagiarism_in_personal_statement_or_elsewhere: false,
           evidence_of_plagiarism_in_personal_statement_or_elsewhere_details: nil,
           references_didn_t_support_application: false,
           references_didn_t_support_application_details: nil,
           honesty_and_professionalism_other_reason_details: nil,
           safeguarding_issues: false,
           information_disclosed_by_candidate_makes_them_unsuitable_to_work_with_children: false,
           information_disclosed_by_candidate_makes_them_unsuitable_to_work_with_children_details: nil,
           information_revealed_by_our_vetting_process_makes_the_candidate_unsuitable_to_work_with_children: false,
           information_revealed_by_our_vetting_process_makes_the_candidate_unsuitable_to_work_with_children_details: nil,
           safeguarding_issues_other_reason_details: nil,
           visa_application_sponsorship: false,
           cannot_sponsor_visa_details: nil,
           additional_advice: false,
           future_applications: false,
           why_are_you_rejecting_this_application_details: nil,
         }],
      )
    end
  end
end
