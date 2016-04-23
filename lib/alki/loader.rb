module Alki
  class Loader
    def self.load(config_file)
      Fiber.new do
        Kernel.load config_file
        Thread.current[:alki_loader_current]
      end.resume
    end

    def initialize(root_dir)
      @root_dir = root_dir
    end

    def load_all
      Dir[File.join(@root_dir,'**','*.rb')].inject({}) do |h,path|
        file = path.gsub(File.join(@root_dir,''),'').gsub(/\.rb$/,'')
        h.merge!(file => Loader.load(path))
      end
    end

    def load(file)
      Loader.load File.expand_path("#{file}.rb",@root_dir)
    end
  end
end

module Kernel
  def Alki(&blk)
    Thread.current[:alki_loader_current] = blk if blk
    ::Alki
  end
end
