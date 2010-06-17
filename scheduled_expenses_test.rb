EXT = '.example'

require 'scheduled_expenses'
require 'test/unit'
require 'fileutils'


class ScheduledExpensesTest < Test::Unit::TestCase
  def test_load_config
    config = load_config
    assert config.has_key?('connection')
    assert_equal 'user@domain.com', config['connection']['email']
  end
  
  def test_load_expenses
    expenses = load_expenses
    assert expenses.has_key?(1)

    assert expenses[1].has_key?('monthly_hosting')
    assert_equal 'ACME', expenses[1]['monthly_hosting']['client']
    assert_equal 'website', expenses[1]['monthly_hosting']['project']
    assert_equal 'services', expenses[1]['monthly_hosting']['category']
    assert_equal 24.50, expenses[1]['monthly_hosting']['amount']
    assert_equal 'monthly hosting expense', expenses[1]['monthly_hosting']['notes']
  end
  
  def test_load_last_run_date_from_scratch
    filename = "last_run_date.txt#{EXT}"
    date = Date.today - 1
    
    # Remove the file if it exists
    FileUtils.rm filename, :force => true
    
    last_run_date = load_last_run_date
    
    assert File.exists? filename
    assert_equal date, last_run_date
  end
  
  def test_load_last_run_date_when_it_exists
    filename = "last_run_date.txt#{EXT}"

    File.open(filename, 'w'){|f| f.puts "2010-01-01"}
    
    last_run_date = load_last_run_date
    
    assert_equal Date.parse('2010-01-01'), last_run_date
  end
end