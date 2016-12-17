require 'alki/override_builder'
require 'alki/support'
require 'alki/overlay_info'

Alki do
  require_dsl 'alki/dsls/dsl'

  init do
    ctx[:root] = build(:group,{})
    ctx[:overlays] = []
  end

  helper :add do |name,elem|
    ctx[:root].children[name.to_sym] = elem
    nil
  end

  helper :build do |type,*args|
    Alki::Support.load_class("alki/assembly/types/#{type}").new *args
  end

  helper :prefix_overlays do |*prefix,overlays|
    overlays.each do |overlay|
      overlay[0].unshift *prefix
    end
    overlays
  end

  helper :update_overlays do |*prefix,overlays|
    ctx[:overlays].push *prefix_overlays(*prefix,overlays)
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
    update_overlays name, grp[:overlays]
  end

  dsl_method :load do |group_name,name=group_name.to_s|
    grp = Alki::Dsl.load(File.expand_path(name+'.rb',ctx[:config_dir]))[:class]
    add name, grp.root
    update_overlays name, grp.overlays
  end

  dsl_method :mount do |name,pkg=name.to_s,**overrides,&blk|
    klass = Alki::Support.load_class pkg
    mounted_assemblies = klass.overlays.map do |(path,info)|
      [path.dup,info]
    end
    update_overlays name, mounted_assemblies

    overrides = Alki::OverrideBuilder.build overrides, &blk
    update_overlays name, overrides[:overlays]

    add name, build(:assembly, klass.root, overrides[:root])
  end

  dsl_method :overlay do |target,overlay,*args|
    (ctx[:overlays]||=[]) << [
      [],
      Alki::OverlayInfo.new(
        target.to_s.split('.').map(&:to_sym),
        overlay.to_s.split('.').map(&:to_sym),
        args
      )
    ]
  end
end
