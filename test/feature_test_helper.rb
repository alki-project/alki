require 'alki'


class Minitest::Spec
  before do
    @test_projects = [
      Alki::Test.fixture_path('example'),
      Alki::Test.fixture_path('tlogger'),
      Alki::Test.fixture_path('auto_group')
    ]
    @test_projects.each do |proj|
      $LOAD_PATH.unshift File.join(proj,'lib')
    end
  end

  after do
    $LOADED_FEATURES.delete_if do |p|
      @test_projects.any? do |proj|
        p.start_with?(File.join(proj,''))
      end
    end
    $LOAD_PATH.delete_if do |p|
      @test_projects.any? do |proj|
        p.start_with?(File.join(proj,''))
      end
    end
    undefine :Example, false
    undefine :Tlogger, false
    undefine :AutoGroupTest, false
    undefine :AlkiTest, false
  end

  def undefine(sym,force=true)
    if force || Object.const_defined?(sym)
      Object.send :remove_const, sym
    end
  end
end
