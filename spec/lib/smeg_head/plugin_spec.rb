require "spec_helper"

describe SmegHead::Plugin do

  let(:plugin) { Class.new(SmegHead::Plugin) }

  it "should be an abstract railtie" do
    SmegHead::Plugin.should be_abstract_railtie
  end

  describe "metadata accessors" do

    it "should define a name accessor" do
      plugin.should respond_to(:plugin_name)
      plugin.plugin_name.should be_nil
      plugin.plugin_name "Test Plugin"
      plugin.plugin_name.should == "Test Plugin"
      plugin.metadata[:name].should == "Test Plugin"
    end

    it "should define a author accessor" do
      plugin.should respond_to(:plugin_author)
      plugin.plugin_author.should be_nil
      plugin.plugin_author "Darcy Laycock"
      plugin.plugin_author.should == "Darcy Laycock"
      plugin.metadata[:author].should == "Darcy Laycock"
    end

    it "should define a version accessor" do
      plugin.should respond_to(:plugin_version)
      plugin.plugin_version.should be_nil
      plugin.plugin_version "v1.0.0"
      plugin.plugin_version.should == "v1.0.0"
      plugin.metadata[:version].should == "v1.0.0"
    end

    it "should define a url accessor" do
      plugin.should respond_to(:plugin_url)
      plugin.plugin_url.should be_nil
      plugin.plugin_url "http://example.com/"
      plugin.plugin_url.should == "http://example.com/"
      plugin.metadata[:url].should == "http://example.com/"
    end

    it "should let you get a hash of all metadata" do
      plugin.metadata.should be_a Hash
      plugin.metadata.should be_empty
      plugin.plugin_author  "Darcy Laycock"
      plugin.plugin_url     "http://example.com/"
      plugin.plugin_version "v1.0.0"
      plugin.metadata.should == {
        :author  => "Darcy Laycock",
        :url     => "http://example.com/",
        :version => "v1.0.0"
      }
    end

    pending "should let inherit a parent class's metadata" do
      plugin.plugin_author "Darcy Laycock"
      child_plugin = Class.new(plugin)
      child_plugin.plugin_author.should == 'Darcy Laycock'
    end

    pending "should let not override the parent class's metadata" do
      plugin.plugin_author "Darcy Laycock"
      child_plugin = Class.new(plugin)
      child_plugin.plugin_author 'Bob Smith'
      child_plugin.plugin_author.should == 'Bob Smith'
      plugin.plugin_author.should == 'Darcy Laycock'
    end

  end

  describe "subscribing to events" do

    around(:each) { |blk| with_hub(SmegHead::Hub.new, &blk) }
    after(:each)  { plugin.teardown_subscriptions! }

    it "should subscribe to events when after initialization"

    it "should let you subscribe with objects" do
      o = Object.new
      mock(o).call(anything) { true }
      plugin.subscribe 'a:b:c', o
      plugin.setup_subscriptions!
      SmegHead.publish 'a:b:c'
    end

    it "should let you subscribe with lambdas" do
      called = false
      plugin.subscribe('a:b:c') { |o| called = true }
      plugin.setup_subscriptions!
      SmegHead.publish 'a:b:c'
      called.should be_true
    end

  end

  describe "extending models" do

    it 'should register it to happen on prepare'

    it 'should dynamically look up the model'

    it 'should include the specified mixin'

    it 'should reinclude it on reloads'

  end

end
