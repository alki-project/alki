lib_dir = File.join(Bundler.root,'lib')

unless $LOAD_PATH.include? lib_dir
  $LOAD_PATH.unshift lib_dir
end
