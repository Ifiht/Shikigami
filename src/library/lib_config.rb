require 'yaml'

class AppSettings
  config_hash = YAML.load(File.read("#{Dir.home}/.config/shikigami/config.yml"))

  def self.exists? (key)
    return config_hash.has_key?(key)
  end

  def self.get (key)
    return config_hash[key]
  end
end
