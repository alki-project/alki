module Alki
  class Generator
    def initialize(root_dir)
      @root_dir = root_dir
      @changes = []
      @triggers = []
    end

    def create(file,contents)
      @changes << [:create,file: file,contents: contents,opts: {}]
    end

    def create_exec(file,contents)
      @changes << [:create,file: file,contents: contents,opts: {exec: true}]
    end

    def check_create(file:, contents:, opts:)
      path = abs_path( file)
      if File.exists? path
        if File.read(path) == contents
          :skip
        end
      end
    end

    def desc_create(file:, contents:, opts: {})
      path = abs_path( file)
      if opts[:exec]
        adj = "executable "
      end
      if File.exists? path
        "Overwriting #{adj}#{file}!"
      else
        "Create #{adj}#{file}"
      end
    end

    def do_create(file:, contents:, opts: {})
      path = abs_path( file)
      FileUtils.mkdir_p File.dirname(path)
      File.write path, contents
      FileUtils.chmod '+x', path if opts[:exec]
    end

    def opt_create(file,contents)
      @changes << [:opt_create,file: file,contents: contents]
    end

    def check_opt_create(file:, contents:)
      if File.exists? abs_path( file)
        :skip
      end
    end

    def desc_opt_create(opts)
      desc_create opts
    end

    def do_opt_create(opts)
      do_create opts
    end

    def add_line(file,line,opts={})
      @changes << [:add_line,file: file,line: line,opts: opts]
    end

    def check_add_line(file:,line:,opts:)
      if File.exists? abs_path(file)
        File.open(file) do |f|
          if opts[:after]
            found = until f.eof?
              break true if f.readline.chomp == opts[:after]
            end
            unless found
              puts "File \"#{file}\" doesn't contain required line #{opts[:after]}"
              return :abort
            end
          end
          until f.eof?
            l = f.readline
            if opts[:match] ? l.chomp.match(opts[:match]) : (l.chomp == line)
              return :skip
            end
          end
        end
      else
        unless @changes.find {|c| [:create,:opt_create].include?(c[0]) && c[1][:file] == file}
          puts "File \"#{file}\" doesn't exist!"
          return :abort
        end
      end
    end

    def desc_add_line(file:,line:,opts:)
      "Add line \"#{line}\" to #{file}"
    end

    def do_add_line(file:,line:,opts:)
      if opts[:after]
        File.write file, File.read(file).sub(/^#{Regexp.quote(opts[:after])}\n/){|m| m + line + "\n"}
      else
        File.open(file,'a') do |f|
          f.puts line
        end
      end
    end

    def trigger(file,cmd)
      @triggers << [file, cmd]
    end

    def check_trigger(changes,file)
      changes.find {|c| c[1][:file] == file}
    end

    def desc_trigger(cmd:)
      "Run \"#{cmd}\""
    end

    def do_trigger(cmd:)
      system cmd
    end

    def check_changes
      puts "Checking preconditions..."
      abort = false
      unless Dir.exists?(@root_dir)
        puts "Root dir doesn't exist"
        exit 1
      end
      do_changes = []
      @changes.each do |(type,args)|
        res = send "check_#{type}", args
        abort = true if res == :abort
        do_changes << [type,args] unless res == :skip
      end
      @triggers.each do |(file,cmd)|
        if check_trigger do_changes, file
          do_changes << [:trigger,cmd: cmd]
        end
      end
      exit 1 if abort
      do_changes
    end

    def print_overview(changes)
      puts "Overview of changes to be made:"

      changes.each do |(type,args)|
        desc = send "desc_#{type}", args
        puts "  #{desc}" if desc
      end
      print "Proceed? "
      resp = STDIN.gets.chomp
      unless resp =~ /^y(es?)?/i
        puts "Aborting"
        exit
      end
    end

    def write
      puts "Using project root: #{@root_dir}\n"
      do_changes = check_changes
      print_overview do_changes

      puts "Writing changes..."
      do_changes.each do |(type,args)|
        send "do_#{type}", args
      end
      puts "Done"
    end

    def abs_path(p)
      File.expand_path(p,@root_dir)
    end
  end
end
