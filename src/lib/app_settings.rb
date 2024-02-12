require "yaml"

class AppSettings
  begin
    @@config_hash = YAML.load(File.read("#{Dir.home}/.config/shikigami/config.yml"))
  rescue
    @@config_hash = {}
  end

  def self.exists?(key)
    return @@config_hash.has_key?(key)
  end

  def get(key)
    return @@config_hash[key]
  end
end
