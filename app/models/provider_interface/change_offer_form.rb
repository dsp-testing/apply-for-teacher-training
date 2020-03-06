module ProviderInterface
  class ChangeOfferForm
    include ActiveModel::Model
    attr_accessor :application_choice, :step, :provider_id, :course_id, :course_option_id

    validates :application_choice, presence: true

    # This is a form for a multi-step process, in which each step depends on the previous ones.
    # Validation needs to take this into account, e.g. it is fine for course_id to be blank if step == :provider
    #
    STEPS = %i(provider course course_option confirm update).freeze
    validates :step, presence: true, inclusion: { in: STEPS, message: '%{value} is not a valid option' }

    def step_after?(symbol)
      STEPS.index(step) > STEPS.index(symbol) if step
    end

    validates_each :provider_id do |record, attr, _value|
      record.errors.add attr, :blank if record.step_after?(:provider) && record.provider_id.blank?
    end

    validates_each :course_id do |record, attr, _value|
      if record.step_after?(:course)
        record.errors.add attr, :blank if record.course_id.blank? || !course_matches_provider?(record)
        record.errors.add attr, :not_open_on_apply if record.course_id.present? && !course_open_on_apply?(record)
      end
    end

    validates_each :course_option_id do |record, attr, _value|
      if record.step_after?(:course_option) && (record.course_option_id.blank? || !course_option_matches_course?(record))
        record.errors.add attr, :blank
      end
    end

    def self.course_matches_provider?(record)
      course = Course.find(record.course_id) if record.course_id
      course && record.provider_id && course.provider.id == record.provider_id
    end

    def self.course_open_on_apply?(record)
      course = Course.find(record.course_id)
      course.open_on_apply
    end

    def self.course_option_matches_course?(record)
      record.course_option_id && CourseOption.find(record.course_option_id).course.id == record.course_id
    end
  end
end
