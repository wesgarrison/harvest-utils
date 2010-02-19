class Hash
  def symbolize_keys
    replace(inject({}) { |h,(k,v)| h[k.to_sym] = v; h })
  end
end
require 'yaml'
require './aiaio-harvest/lib/harvest.rb'

@harvest = Harvest(YAML.load_file('config.yml').symbolize_keys)
