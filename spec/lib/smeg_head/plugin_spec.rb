require "spec_helper"

describe SmegHead::Plugin do

  it "should be an abstract railtie"

  describe "metadata accessors" do

    it "should define a name accessor"

    it "should define a author accessor"

    it "should define a version accessor"

    it "should define a url accessor"

    it "should let you get a hash of all metadata"

    it "should let inherit a parent class's metadata"

    it "should let not override the parent class's metadata"

  end

  describe "subscribing to events" do

    it "should subscribe to events when the application is loaded"

    it "should not subscribe if the hub isn't loaded"

    it "should let you subscribe with objects"

    it "should let you subscribe with lambdas"

  end

  describe "extending models" do

    it 'should register it to happen on prepare'

    it 'should dynamically look up the model'

    it 'should include the specified mixin'

    it 'should reinclude it on reloads'

  end

end
