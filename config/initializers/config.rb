CONFIG = HashWithIndifferentAccess.new YAML.load(File.read(Rails.root.join('config/config.yml')))[Rails.env]
