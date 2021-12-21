module Blueprint
  BASE_DIR = Path[String.new(ARGV_UNSAFE.value)].expand.parent

  def self.path(*dirs)
    File.join(BASE_DIR, "blueprints", *dirs)
  end

  def self.load_list(*dirs)
    File.read(path(*dirs)).split("\n")
  end
end
