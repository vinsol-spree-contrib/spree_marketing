require 'factory_bot'

Dir['lib/factories/**'].each do |f|
  load File.expand_path(f)
end
