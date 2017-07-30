require 'alki/feature_test'
require 'concurrent'

describe 'Multithreading' do
  it 'should cause access to block while assembly is building elements' do
    cb = Concurrent::CyclicBarrier.new 2
    e = Concurrent::Event.new

    assembly = Alki.create_assembly do
      service :svc do
        cb.wait
        e.wait
      end

      service :svc2 do
        :val
      end
    end
    obj = assembly.new
    thread = Thread.new { obj.svc }
    cb.wait
    thread2 = Thread.new { obj.svc2 }
    sleep 0.1
    thread2.alive?.must_equal true
    e.set
    thread.join
    thread2.join
  end

  it 'should allow concurrent access when not building elements' do
    cb = Concurrent::CyclicBarrier.new 3
    assembly = Alki.create_assembly do
      func :f do
        cb.wait
        cb.wait
      end

      func :f2 do
        cb.wait
      end
    end
    obj = assembly.new
    thread = Thread.new { obj.f }
    thread2 = Thread.new { cb.wait; obj.f2 }
    cb.wait
    sleep 0.1
    thread.alive?.must_equal true
    thread2.alive?.must_equal true
    cb.wait
    sleep 0.1
    thread.alive?.must_equal false
    thread2.alive?.must_equal false

    thread.join
    thread2.join
  end
end
