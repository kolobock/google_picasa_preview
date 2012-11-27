require 'picasa/base'
Dir["lib/picasa/*.rb"].each do |f|
  require f.gsub(/lib\//, '') unless f =~ /base.rb/
end
