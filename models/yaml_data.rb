require 'yaml'
require 'zlib'

class YamlData
  attr_accessor :db,
                :teams,
                :seasons,
                :winnings

  def initialize(path)
    yaml_files = Dir.glob(File.join(path, "*.yml")).sort
    self.db =  {}

    yaml_files.each do |file|
      self.db.merge!(YAML.load(File.read(file)).symbolize_keys!)
    end

    @teams    = self.db[:teams]
    @seasons  = self.db[:seasons]
    @winnings = self.db[:winnings]
  end

  def dump(io=$stdout)
    self.db.stringify_keys!
    YAML.dump(self.db, io)
  end

  def write(path=".")
    self.db[:winnings] = self.winnings
    self.db.stringify_keys!
    File.open(File.join(path, "db.yml"), "w") do |out|
      YAML.dump(self.db, out)
    end
  end

  def gzip(path=".")
    gz = Zlib::GzipWriter.open(File.join(path, "db.yml.gz"))
    gz.write(File.read(File.join(path, "db.yml")))
    gz.close
  end
end
