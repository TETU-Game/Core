module TETU::Blueprint
  BASE_DIR = Path[String.new(ARGV_UNSAFE.value)].expand.parent

  def self.path(*parts)
    File.join(BASE_DIR, "blueprints", *parts)
  end

  def self.all(*parts, filter : Regex) : Array(String)
    path = path(*parts)
    Dir.new(path)
      .children
      .select!{ |f| f.match(filter) }
      .map { |f| File.join(path, f) }
  end

  def self.map(*parts, filter : Regex, &block)
    all(*parts, filter: filter).map { |f| yield f }
  end

  def self.load_list(*parts)
    File.read(path(*parts)).split("\n")
  end

  def self.load_yaml(*parts)
    YAML.parse(File.read(path(*parts)))
  end
end
