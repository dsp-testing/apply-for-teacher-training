require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByStatus do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  context 'applications by status table data' do
    subject(:statistics) { described_class.new.table_data }

    it "returns table data for 'applications by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited',                           2, 1, 3],
         ['Conditions pending',                  1, 0, 1],
         ['Deferred',                            1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions',         4, 0, 4],
         ['Declined an offer',                   1, 0, 1],
         ['Withdrew an application',             1, 1, 2],
         ['Application rejected',                4, 0, 4]]
      end

      expect_column_totals(15, 2, 17)
    end
  end

  context 'candidates by status table data' do
    subject(:statistics) { described_class.new(by_candidate: true).table_data }

    it "returns table data for 'candidates by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited',                           2, 1, 3],
         ['Conditions pending',                  1, 0, 1],
         ['Deferred',                            1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions',         1, 0, 1],
         ['Declined an offer',                   1, 0, 1],
         ['Withdrew an application',             1, 1, 2],
         ['Application rejected',                1, 0, 1]]
      end

      expect_column_totals(9, 2, 11)
    end
  end
end
