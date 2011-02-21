require 'spec_helper'

describe SmegHead::Hub do

  let(:hub) { SmegHead::Hub.new }

  let(:subscriber_klass) do
    Class.new do

      def published
        @published ||= []
      end

      def call(ctx)
        published << ctx
      end

    end
  end

  let(:ctx_from_proc) { [] }

  let(:subscriber_proc) do
    proc { |ctx| ctx_from_proc << ctx }
  end

  describe '#subscribe' do

    it 'should let you subscribe to a top level item'

    it 'should let you subscribe to a nested item'

    it 'should let you pass an object'

    it 'should let you pass a block'

    it 'should return a subscription'

    it 'should automatically subscribe to lower level nested events'

    it 'should raise an error when subscribing with an object that does not provide call'

  end

  describe '#unsubscribe' do

    it 'should remove an object from the subscription pool'

    it 'should return the subscription'

    it 'should do nothing with a blank item'

  end

  describe '#publish' do

    let(:nested_a)    { subscriber_klass.new }
    let(:nested_b)    { subscriber_klass.new }
    let(:top_level_a) { subscriber_klass.new }
    let(:top_level_b) { subscriber_klass.new }

    before :each do
      hub.subscribe 'hello',       top_level_a
      hub.subscribe 'hello:world', nested_a
      hub.subscribe 'foo',         top_level_b
      hub.subscribe 'foo:bar',     nested_b
    end

    it 'should add the path parts for a top level call' do
      mock(top_level_a).call(hash_including(:path_parts => %w()))
      hub.publish 'hello', {}
    end

    it 'should add the path parts for a nested call' do
      mock(top_level_a).call(hash_including(:path_parts => %w(world)))
      mock(nested_a).call(hash_including(:path_parts => %w()))
      hub.publish 'hello:world', {}
    end

    it 'should unpack path keys if provided' do
      mock(top_level_a).call(hash_including(:model_name => 'world'))
      mock(nested_a).call(hash_including(:model_name => 'world'))
      hub.publish 'hello:world', :path_keys => [nil, :model_name]
    end

    it 'should add the full path to the publish' do
      mock(top_level_a).call(hash_including(:full_path => 'hello:world'))
      mock(nested_a).call(hash_including(:full_path => 'hello:world'))
      hub.publish 'hello:world', {}
    end

    it 'should notify all subscriptions under the path'

    it 'should not notify unmatched subscriptions on a simple case'

    it 'should not notify unmatched subscriptions on a nested case'

  end

end
