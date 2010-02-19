require 'yaml'
require './aiaio-harvest/lib/harvest.rb'
require 'term/ansicolor'
include Term::ANSIColor

class Hash
  def symbolize_keys
    replace(inject({}) { |h,(k,v)| h[k.to_sym] = v; h })
  end
end

def who_from_description(desc)
  @users.keys.each do |user|
    return user if desc.include?(user)
  end
  return "Unknown"
end

def pay_from_hours(who, vals)
  return if @users[who].nil?
  if @users[who].has_key?('hourly')
    employee_amount = vals[:hours].to_f * @users[who]['hourly'].to_f
  else
    employee_amount = vals[:amounts].to_f * @users[who]['commission'].to_f / 100.0
  end
  employee_amount = employee_amount.round(2)
  company_amount  = vals[:amounts].to_f - employee_amount
    
  print("  ==> #{who} split: ", green, "$#{employee_amount}", clear, "  |  Company split: ", green, "$#{company_amount}", clear, "\n")
end

config = YAML.load_file('config.yml')
@harvest = Harvest(config['connection'].symbolize_keys)
@users = config['users']
puts @users.inspect
inv_nums = ARGV

inv_nums.each do |inv_num|
  invoice = @harvest.invoices.find_by_number(inv_num)

  totals = {}
  invoice.parsed_line_items.each do |line|
    who = who_from_description(line['description'])
    who = line['description'] if "Product" == line['kind']
    totals[who] ||= {}
    totals[who][:hours] ||= 0
    totals[who][:amounts] ||= 0
    totals[who][:rate] ||= []

    totals[who][:hours] += line['quantity'].to_f
    totals[who][:amounts] += line['amount'].to_f
    totals[who][:rate] << line['unit_price'] unless totals[who][:rate].include?(line['unit_price'])
  end

  print cyan, "\n#{'=' * 60}", clear
  
  print "\nReport for invoice ", green, bold, inv_num, clear, "\n"
  puts @harvest.clients.find(invoice.client_id).name
  puts "Invoice date: #{invoice.issued_at}"
  puts "\n#{'-' * 60}"
  inv_total = 0.0
  totals.each do |who, vals|
    puts "#{who} : #{vals[:hours]} = #{vals[:amounts]} @ #{vals[:rate].join(' | ')}"
    pay_from_hours(who, vals)
    inv_total += vals[:amounts]
  end
  puts "total:  #{inv_total}"
end
