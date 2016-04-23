require 'minitest/autorun'
Bundler.setup(:default,:test)

class Minitest::Spec
  def app_root
    Bundler.root
  end

  def lib_dir
    File.join app_root, 'lib'
  end

  def tests_root
    File.join app_root, 'test'
  end

  def fixtures_path
    File.join(tests_root, 'fixtures')
  end

  def fixture_path(fixture)
    File.join(fixtures_path, fixture)
  end

  def load_fixture(fixture)
    require fixture_path(fixture)
  end
end
