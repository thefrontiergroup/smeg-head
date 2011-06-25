shared_examples_for 'a sluggable model' do

  it 'should have a to_slug method' do
    subject_class.new.should respond_to(:to_slug)
  end

  it 'should automatically generate a slug on save'

  it 'should have a slugged finder method' do
    subject_class.should respond_to(:find_using_slug)
    subject_class.should respond_to(:find_using_slug!)
  end

  it 'should include the slugged modules' do
    subject_class.should be < Slugged::ActiveRecordMethods::InstanceMethods
  end

end