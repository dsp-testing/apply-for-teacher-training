# NOTE: This component is used by both provider and support UIs
class GcseQualificationCardsComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def maths
    application_form.maths_gcse
  end

  def english
    application_form.english_gcse
  end

  def science
    application_form.science_gcse
  end

  def candidate_does_not_have
    'Candidate does not have this qualification yet'
  end

  def subject(qualification)
    if [ApplicationQualification::SCIENCE_SINGLE_AWARD,
        ApplicationQualification::SCIENCE_DOUBLE_AWARD,
        ApplicationQualification::SCIENCE_TRIPLE_AWARD].include? qualification.subject
      'Science'
    else
      qualification.subject.capitalize
    end
  end

  def institution_country(qualification)
    COUNTRIES[qualification.institution_country]
  end

  def presentable_qualification_type(qualification)
    if qualification.other_uk_qualification_type.present?
      qualification.other_uk_qualification_type
    elsif qualification.non_uk_qualification_type.present?
      qualification.non_uk_qualification_type
    else
      I18n.t("application_form.gcse.qualification_types.#{qualification.qualification_type}", default: qualification.qualification_type)
    end
  end

  def naric_statement(qualification)
    if qualification.naric_reference.present? && qualification.comparable_uk_qualification.present?
      "UK NARIC statement #{qualification.naric_reference} says this is comparable to a #{qualification.comparable_uk_qualification}."
    end
  end

  def grade_details(qualification)
    case qualification.subject
    when ApplicationQualification::SCIENCE_TRIPLE_AWARD
      grades = qualification.structured_grades
      [
        "#{grades['biology']} (Biology)",
        "#{grades['chemistry']} (Chemistry)",
        "#{grades['physics']} (Physics)",
      ]
    when ApplicationQualification::SCIENCE_DOUBLE_AWARD
      ["#{qualification.grade} (Double award)"]
    when ApplicationQualification::SCIENCE_SINGLE_AWARD
      ["#{qualification.grade} (Single award)"]
    when ->(_n) { qualification.structured_grades }
      present_structured_grades(qualification)
    else
      [qualification.grade]
    end
  end

  def present_structured_grades(qualification)
    grades = JSON.parse(qualification.structured_grades)
    grades.map do |k, v,|
      case k
      when 'english_single_award'
        "#{v} (English Single award)"
      when 'english_double_award'
        "#{v} (English Double award)"
      when 'english_studies_single_award'
        "#{v} (English Studies Single award)"
      when 'english_studies_double_award'
        "#{v} (English Studies Double award)"
      else
        "#{v} (#{k.humanize.titleize})"
      end
    end
  end
end
