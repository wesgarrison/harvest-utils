 require 'yaml'
 require './aiaio-harvest/lib/harvest.rb'
# require 'term/ansicolor'
# include Term::ANSIColor

def load_config
  YAML.load_file("config.yml#{EXT}")
end

def load_expenses
  YAML.load_file("expenses.yml#{EXT}")
end

def load_last_run_date
  filename = "last_run_date.txt#{EXT}"
  
  if File.exists? filename
    File.open(filename, 'r') {|f| Date.parse(f.gets.chomp)}
  else
    date = (Date.today - 1).strftime('%Y-%m-%d')
    File.open(filename, 'w') {|f| f.puts date}
    Date.parse(date)
  end
end

# Connect to harvest
config = load_config
@harvest = Harvest(config['connection'].symbolize_keys!)

# Load recurring expenses
expenses = load_expenses

# Load last run date
last_run_date = load_last_run_date

# Cycle through each run date
(last_run_date + 1).up_to(Date.today) do |date|
  # Cycle through this day's expenses
  
  
    # Save to harvest

end
    

# Save current run date