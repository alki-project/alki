# What is Alki?

Alki is a framework for creating projects that are modular, testable, and well organized.

It's goal is to remove uncertainty and friction when building Ruby projects, allowing developers to focus on implementing business logic.

# Synopsis

Best place to start would be to check out some examples:

* https://github.com/alki-project/alki-example
* https://github.com/alki-project/alki/test/fixtures/example

# The Alki Assembly

If a set of classes are the raw materials of your product, an Assembly is the finished product, ready to ship.

To get there, you provide Alki with your assembly definition, which acts as the instructions for how to piece together your classes and objects.

Assembly definitions are written in a simple DSL and are transformed into classes.

```ruby
require 'alki'

class Printer
  def print(msg)
    puts msg
  end
end

MyAssembly = Alki.create_assembly do
  service :printer do
    Printer.new
  end
end

MyAssembly.new.printer.print "hello world"
```

## Project Assemblies

While Assemblies can be created directly as in the previous example, most
of the time an entire project will contain instructions for a single Assembly.

To ease this use case, Alki supports a simple standard project layout.

* `config` and `lib` directories in your project root.
* A file called `config/assembly.rb` with your assembly definition inside an `Alki do ... end` block.
* A file under lib that has the name of your project. For example if your project was called `MyProject`, create a file called `lib/my_project.rb`.
  Inside the file put the following two lines:
  
    ```ruby
require 'alki'
Alki.project_assembly!
    ```
