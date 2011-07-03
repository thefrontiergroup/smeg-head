module MiscHelpers

  def subject_class
    self.class.describes || self.class.description
  end

  def with_hub(hub, &blk)
    begin
      old_hub, SmegHead.hub = SmegHead.hub, hub
      yield if block_given?
    ensure
      SmegHead.hub = old_hub
    end
  end

  RSpec::Matchers.define :exit_sh_manager do
    match do |block|
      begin
        mock($stderr).puts.with_any_args
        mock.instance_of(SmegHead::Shell::Manager).exit 1
        block.call
        RR.verify
      ensure
        RR.reset
      end
    end
  end

  def with_environment(env_hash)
    previous_env = {}
    env_hash.each_pair do |k, v|
      k = k.to_s
      previous_env[k] = ENV[k]
      ENV[k] = v.to_s
    end
    yield if block_given?
  ensure
    previous_env.each_pair { |k, v| ENV[k] = v }
  end

end