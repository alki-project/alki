require_relative '../test_helper'
require 'alki/package_processor'

describe Alki::PackageProcessor do
  def pkg(pkg,overrides ={})
    {
        type: :package,
        children: pkg,
        overrides: overrides
    }
  end
  def group(children={})
    {
        type: :group,
        children: children
    }
  end
  def svc(sym)
    {
        type: :service,
        block: -> { sym }
    }
  end
  def factory(sym)
    {
        type: :factory,
        block: -> { sym }
    }
  end
  before do
    @pe = Alki::PackageProcessor.new
    @pkg1 = {
        a: svc(:orig1_a),
        b: svc(:orig1_b),
        c: group
    }
    @desc = {
        a: group(
            test: svc(:a_test)
        ),
        b: svc(:b),
        test: svc(:test),
        pkg1: pkg(
            @pkg1,
            b: svc(:orig1_b_or)
        )
    }
  end

  def scope(pkg,path)
    @pe.lookup(pkg,path)[:scope]
  end

  describe :lookup do
    it 'should identify services and return their block and a scope' do
      pkg = {
          a: svc(:a)
      }
      result = @pe.lookup(pkg,[:a])
      result[:type].must_equal :service
      result[:block].call.must_equal :a
      result[:scope].must_be_instance_of Hash
    end

    it 'should identify factory and return their block and a scope' do
      pkg = {
          a: factory(:a)
      }
      result = @pe.lookup(pkg,[:a])
      result[:type].must_equal :factory
      result[:block].call.must_equal :a
      result[:scope].must_be_instance_of Hash
    end

    it 'should identify groups and return their children' do
      pkg2 = {
          e: svc(:e)
      }
      pkg = {
          a: svc(:a),
          b: group(
              c: svc(:c),
              d: pkg(
                  pkg2,
                  f: svc(:f)
              )
          ),
      }
      @pe.lookup(pkg,[]).must_equal(
          type: :group, children: {a: [:a], b: [:b]})
      @pe.lookup(pkg,[:b]).must_equal(
          type: :group, children: {c: [:b,:c],d: [:b,:d]})
      @pe.lookup(pkg,[:b,:d]).must_equal(
          type: :group, children: {e: [:b,:d,:e],f: [:b,:d,:f]})
      @pe.lookup(pkg,[:b,:d,:orig]).must_equal(
          type: :group, children: {e: [:b,:d,:orig,:e]})
    end
  end

  describe :lookup_scope do
    it 'should contain a root item for the tree root' do
      pkg = {
          a: svc(:a)
      }
      scope(pkg,[:a]).must_equal(root: [],a: [:a])
    end

    it 'should return all visible items for the given context' do
      pkg = {
          a: svc(:a),
          b: group(
              c: svc(:c),
              d: svc(:d),
          )
      }
      scope(pkg,[:b,:c]).must_equal(root: [], a: [:a], b: [:b], c: [:b,:c], d: [:b,:d])
    end

    it 'should respect shadowing of symbols' do
      pkg = {
          a: svc(:a),
          b: group(
              a: svc(:a),
              c: svc(:c),
          )
      }
      scope(pkg,[:b,:c]).must_equal(root: [], a: [:b,:a], b: [:b], c: [:b,:c])
    end

    it 'should hide parent scope of context is in a package' do
      pkg = {
          a: svc(:a),
          b: pkg(
              c: svc(:c),
              d: svc(:d),
          )
      }
      scope(pkg,[:b,:c]).must_equal(root: [:b], c: [:b,:c], d: [:b,:d])
    end

    it 'should respect package overrides' do
      pkg2 = {
          c: svc(:c),
      }
      pkg = {
          a: svc(:a),
          b: pkg(
              pkg2,
              d: svc(:d),
          )
      }
      scope(pkg,[:b,:c]).must_equal(root: [:b], c: [:b,:c], d: [:b,:d])
    end

    it 'should not change root and should add :orig symbol to override contexts' do
      pkg2 = {
          d: svc(:d),
      }
      pkg = {
          a: svc(:a),
          b: pkg(
              pkg2,
              c: svc(:c),
          )
      }
      scope(pkg,[:b,:c]).must_equal(root: [],pkg: [:b,:orig], c: [:b,:c], a: [:a], b: [:b])
    end

    it 'should respect :orig symbol in path to access non-overriden services' do
      pkg2 = {
          c: svc(:c),
          d: svc(:d),
      }
      pkg = {
          a: svc(:a),
          b: pkg(
              pkg2,
              c: svc(:c),
          )
      }
      scope(pkg,[:b,:orig,:c]).must_equal(root: [:b], c: [:b,:c], d: [:b,:d])
    end

    it 'should handle nested packages' do
      pkg2 = {
          e: svc(:e),
      }
      pkg = {
          a: svc(:a),
          b: pkg(
              c: svc(:c),
              d: pkg(
                  pkg2,
                  f: svc(:f),
              )
          )
      }
      scope(pkg,[:b,:d,:e]).must_equal(root: [:b,:d], e: [:b,:d,:e], f: [:b,:d,:f])
      scope(pkg,[:b,:d,:f]).must_equal(root: [:b], pkg: [:b,:d,:orig], d: [:b,:d], c: [:b,:c], f: [:b,:d,:f])
    end

    it 'should handle nested packages in overrides' do
      pkg2 = {
          c: svc(:c),
      }
      pkg3 = {
          e: svc(:e),
      }
      pkg = {
          a: svc(:a),
          b: pkg(
              pkg2,
              d: pkg(
                  pkg3,
                  f: svc(:f)
              )
          )
      }
      scope(pkg,[:b,:d,:e]).must_equal(root: [:b,:d], e: [:b,:d,:e], f: [:b,:d,:f])
    end
  end
end