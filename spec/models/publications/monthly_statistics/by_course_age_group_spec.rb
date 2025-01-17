require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByCourseAgeGroup do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course age group'" do
    expect_report_rows(column_headings: ['Course phase', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Primary',           1, 1, 0, 1, 4, 0, 7],
       ['Secondary',         3, 1, 1, 0, 0, 14, 19],
       ['Further education', 0, 0, 0, 0, 0, 1, 1]]
    end

    expect_column_totals(4, 2, 1, 1, 4, 15, 27)
  end
end
