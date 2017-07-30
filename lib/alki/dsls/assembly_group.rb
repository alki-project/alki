require 'alki/override_builder'
require 'alki/support'
require 'alki/overlay_info'

Alki do
  init do
    ctx[:root] = build(:group,{})
    ctx[:meta] = []
    ctx[:addons] ||= []
    ctx[:addons].each do |addon|
      require_dsl addon
    end
  end

  helper :add do |name,elem|
    if defined?(@tags) && @tags
      ctx[:meta] << [[name.to_sym],build_meta(:tags,@tags)]
      @tags = nil
    end
    ctx[:root].children[name.to_sym] = elem
    nil
  end

  helper :build do |type,*args|
    Alki.load("alki/assembly/types/#{type}").new *args
  end

  helper :build_meta do |type,*args|
    Alki.load("alki/assembly/meta/#{type}").new *args
  end

  helper :add_overlay do |type,target,overlay,args|
    (ctx[:meta]||=[]) << [
      [],
      build_meta(
        :overlay,
        type, target.to_s.split('.').map(&:to_sym),
        overlay.to_s.split('.').map(&:to_sym),
        args
      )
    ]
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

  dsl_method :use do |addon_name|
    addon = Alki.load addon_name
    if addon.respond_to?(:alki_addon)
      addon = addon.alki_addon
    end
    require_dsl addon
    ctx[:addons] << addon
  end

  dsl_method :tag do |*tags,**value_tags|
    unless tags.all?{|t| t.is_a? Symbol }
      raise "Tags must be symbols"
    end
    tags.each {|tag| value_tags[tag] = true }
    @tags = value_tags
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
    grp = Alki::Dsls::AssemblyGroup.build(addons: ctx[:addons], &blk)
    add name, grp[:root]
    update_meta name, grp[:meta]
  end

  dsl_method :auto_group do |name,dir,callable,*args|
    grp = build(:group)
    dir = File.join(File.expand_path(dir,ctx[:config_dir]),"")
    Dir.glob(File.join(dir,'**','*.rb')).each do |path|
      require_path = Alki::Loader.lookup_name path
      if require_path
        elems = path[dir.size..-1].chomp('.rb').split('/')
        *parents,basename = elems
        parent_group = parents.inject(grp) do |group,parent|
          group.children[parent.to_sym] ||= build(:group)
        end
        parent_group.children[basename.to_sym] = build :service,-> {
          lookup(callable).call require_path, *args
        }
      end
    end
    add name, grp
  end

  dsl_method :load do |group_name,name=group_name.to_s|
    unless ctx[:prefix]
      raise "Load command is not available without a config directory"
    end
    grp = Alki.load(File.join(ctx[:prefix],name))
    add group_name, grp.root
    update_meta group_name, grp.meta
  end

  dsl_method :mount do |name,pkg=name.to_s,**overrides,&blk|
    klass = Alki.load pkg
    mounted_meta = klass.meta.map do |(path,type,info)|
      [path.dup,type,info]
    end
    update_meta name, mounted_meta

    overrides = Alki::OverrideBuilder.build overrides, &blk
    update_meta name, overrides.meta

    add name, build(:assembly, klass.root, overrides.root)
  end

  dsl_method :try_mount do |name,pkg=name.to_s,**overrides,&blk|
    begin
      mount name,pkg,overrides,&blk
    rescue LoadError
      nil
    end
  end

  dsl_method :reference_overlay do |target,overlay,*args|
    add_overlay :reference, target, overlay, args
  end

  dsl_method :overlay do |target,overlay,*args|
    add_overlay :value, target, overlay, args
  end
end
