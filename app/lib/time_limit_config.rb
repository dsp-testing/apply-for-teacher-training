class TimeLimitConfig
  class Days
    attr_reader :count, :type

    def initialize(count:, type:)
      raise ArgumentError, 'Argument is not an integer' unless count.is_a?(Integer)
      raise ArgumentError, 'Argument is not :calendar or :working' unless (type == :calendar) || (type == :working)

      @count = count
      @type = type
    end

    def to_days
      type == :calendar ? count.days : count.business_days
    end

    def to_s
      "#{@count} #{@type} #{'day'.pluralize(@count)}"
    end
  end

  Rule = Struct.new(:from_date, :to_date, :limit)

  def self.minimum_hours_between_chaser_emails
    48
  end

  def self.chase_referee_by
    7
  end

  def self.replace_referee_by
    14
  end

  def self.second_chase_referee_by
    21
  end

  def self.additional_reference_chase_calendar_days
    28
  end

  def self.stale_application_rules
    working_days = FeatureFlag.active?(:continuous_applications) ? 30 : 40

    [
      Rule.new(nil, nil, working_days),
      Rule.new(Time.zone.local(RecruitmentCycle.current_year, 6, 30, 23, 59, 59), nil, 20),
    ]
  end

  def self.rules
    {
      reject_by_default: stale_application_rules,
      decline_by_default: [
        Rule.new(nil, nil, 10),
      ],
      chase_provider_before_rbd: [
        Rule.new(nil, nil, 20),
        Rule.new(Time.zone.local(RecruitmentCycle.current_year, 6, 30, 23, 59, 59), nil, 10),
      ],
      chase_candidate_before_dbd: [
        Rule.new(nil, nil, 5),
      ],
    }
  end

  def self.limits_for(rule)
    rules[rule.to_sym]
  end
end
