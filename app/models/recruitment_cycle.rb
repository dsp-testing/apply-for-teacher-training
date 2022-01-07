module RecruitmentCycle
  CYCLES = {
    '2022' => '2021 to 2022',
    '2021' => '2020 to 2021',
    '2020' => '2019 to 2020',
  }.freeze

  def self.cycle_string(year)
    cycle = CYCLES.fetch(year.to_s)
    current_year.to_s == year.to_s ? "#{cycle} - current" : cycle
  end

  def self.current_year
    CycleTimetable.current_year
  end

  def self.next_year
    CycleTimetable.next_year
  end

  def self.previous_year
    current_year - 1
  end

  def self.years_visible_to_providers
    [current_year, previous_year]
  end

  def self.years_visible_in_support
    [2022, 2021, 2020, 2019]
  end

  def self.cycle_name(year = current_year)
    "#{year - 1} to #{year}"
  end

  def self.verbose_cycle_name(year = current_year)
    "October #{year - 1} to September #{year}"
  end
end
