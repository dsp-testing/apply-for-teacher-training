FactoryBot.define do
  factory :candidate do
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    sign_up_email_bounced { false }
    last_signed_in_at { created_at || Time.zone.now }

    transient do
      skip_candidate_api_updated_at { false }
    end

    callback(:after_create) do |candidate, evaluator|
      if evaluator.skip_candidate_api_updated_at
        candidate.candidate_api_updated_at = nil
        candidate.save
      end
    end
  end
end
