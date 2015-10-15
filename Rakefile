require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.name = 'test:unit'
  t.pattern = "test/unit/*_test.rb"
end

Rake::TestTask.new do |t|
  t.name = 'test:feature'
  t.pattern = "test/feature/*_test.rb"
end

Rake::TestTask.new do |t|
  t.name = 'test:integration'
  t.pattern = "test/integration/*_test.rb"
end

Rake::TestTask.new do |t|
  t.name = 'test:page'
  t.pattern = "test/page/*_test.rb"
end

Rake::TestTask.new do |t|
  t.name = 'test'
  t.pattern = "test/*/*_test.rb"
end

task default: [:test]