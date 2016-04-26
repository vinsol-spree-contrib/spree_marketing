require 'factory_girl'

Dir["lib/factories/**"].each do |f|
  load File.expand_path(f)
end
