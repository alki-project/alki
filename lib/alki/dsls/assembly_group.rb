require 'alki/override_builder'
require 'alki/support'
require 'alki/overlay_info'

Alki do
  init do
    ctx[:root] = build(:group,{})
    ctx[:meta] = []
  end

  helper :add do |name,elem|
    if @tags
      ctx[:meta] << [[name.to_sym],:tags,@tags]
      @tags = nil
    end
    ctx[:root].children[name.to_sym] = elem
    nil
  end

  helper :build do |type,*args|
    Alki.load("alki/assembly/types/#{type}").new *args
  end

  helper :prefix_meta do |*prefix,meta|
    meta.each do |data|
      data[0].unshift *prefix.map(&:to_sym)
    end
    meta
  end

  helper :update_meta do |*prefix,meta|
    ctx[:meta].push *prefix_meta(*prefix,meta)
  end

  dsl_method :tag do |*tags|
    unless tags.all?{|t| t.is_a? Symbol }
      raise "Tags must be symbols"
    end
    @tags = tags
  end

  dsl_method :config_dir do
    ctx[:config_dir]
  end

  dsl_method :set do |name,value=nil,&blk|
    if blk
      add name, build(:proc_value, blk)
    else
      add name, build(:value, value)
    end
  end

  dsl_method :service do |name,&blk|
    add name, build(:service, blk)
  end

  dsl_method :factory do |name,&blk|
    add name, build(:factory, blk)
  end

  dsl_method :func do |name,&blk|
    add name, build(:func, blk)
  end

  dsl_method :group do |name,&blk|
    grp = Alki::Dsls::AssemblyGroup.build(&blk)
    add name, grp[:root]
    update_meta name, grp[:meta]
  end

  dsl_method :load do |group_name,name=group_name.to_s|
    unless ctx[:prefix]
      raise "Load command is not available without a config directory"
    end
    grp = Alki.load(File.join(ctx[:prefix],name))
    add name, grp.root
    update_meta name, grp.meta
  end

  dsl_method :mount do |name,pkg=name.to_s,**overrides,&blk|
    klass = Alki.load pkg
    mounted_meta = klass.meta.map do |(path,type,info)|
      [path.dup,type,info]
    end
    update_meta name, mounted_meta

    overrides = Alki::OverrideBuilder.build overrides, &blk
    update_meta name, overrides[:meta]

    add name, build(:assembly, klass.root, overrides[:root])
  end

  dsl_method :overlay do |target,overlay,*args|
    (ctx[:meta]||=[]) << [
      [], :overlay,
      Alki::OverlayInfo.new(
        target.to_s.split('.').map(&:to_sym),
        overlay.to_s.split('.').map(&:to_sym),
        args
      )
    ]
  end
end
