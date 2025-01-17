require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::BySecondarySubject do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it 'correctly generates table data' do
    expect_report_rows(column_headings: ['Subject', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Art and design',           0, 0, 0, 0, 0, 1, 1],
       ['Biology',                  0, 1, 0, 0, 0, 2, 3],
       ['Business studies',         2, 0, 0, 0, 0, 0, 2],
       ['Chemistry',                0, 0, 0, 0, 0, 1, 1],
       ['Drama',                    0, 0, 0, 0, 0, 2, 2],
       ['English',                  0, 0, 0, 0, 0, 1, 1],
       ['History',                  0, 0, 0, 0, 0, 1, 1],
       ['Mathematics',              0, 0, 0, 0, 0, 2, 2],
       ['Modern foreign languages', 1, 0, 0, 0, 0, 2, 3],
       ['Physics',                  0, 0, 0, 0, 0, 1, 1],
       ['Other',                    0, 0, 1, 0, 0, 1, 2]]
    end

    expect_column_totals(3, 1, 1, 0, 0, 14, 19)
  end
end
