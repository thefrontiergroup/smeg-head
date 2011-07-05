require 'spec_helper'

require 'smeg_head/shell'

describe SmegHead::Shell::Manager do

  describe 'running the shell manager' do

    let(:ssh_public_key) { SshPublicKey.make! }
    let(:repository)     { Repository.make! :owner => ssh_public_key.owner }

    let(:manager) { Object.new }

    before :each do
      stub(manager).path { Rails.root.join('tmp', 'test-repo-path') }
      stub.instance_of(SmegHead::Shell::Manager).manager { manager }
      stub(Repository).from_path { repository }
    end

    it 'should raise an error without a valid ssh public key' do
      expect { SmegHead::Shell::Manager.start [] }.to exit_sh_manager
      expect { SmegHead::Shell::Manager.start [''] }.to exit_sh_manager
      expect { SmegHead::Shell::Manager.start %w(0) }.to exit_sh_manager
      expect { SmegHead::Shell::Manager.start [(ssh_public_key.id + 1).to_s] }.to exit_sh_manager
    end

    describe 'executing git' do

      it 'should correctly call receive pack when expected' do
        mock(manager).receive_pack!
        with_repo_verb :receive do
          SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
        end
      end

      it 'should correctly call upload pack when expected' do
        mock(manager).upload_pack!
        with_repo_verb :upload do
          SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
        end
      end

      it 'should raise an error when there is no command' do
        with_environment 'SSH_ORIGINAL_COMMAND' => nil do
          expect { SmegHead::Shell::Manager.start [ssh_public_key.id.to_s] }.to exit_sh_manager
        end
      end

      it 'should raise an error when the command is invalid' do
        with_environment 'SSH_ORIGINAL_COMMAND' => 'rm -rf /some/non-existant/file' do
          expect { SmegHead::Shell::Manager.start [ssh_public_key.id.to_s] }.to exit_sh_manager
        end
      end

    end

    describe 'permissions checks' do

      describe 'upload-pack' do

        it 'should perform a top level readable check' do
          stub(manager).upload_pack!
          mock(repository).readable_by?(ssh_public_key) { true }
          with_repo_verb :upload do
            SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
          end
        end

        it 'should execute the command if the given permissions exist' do
          stub(repository).readable_by?(ssh_public_key) { true }
          mock(manager).upload_pack!
          with_repo_verb :upload do
            SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
          end
        end

        it 'should exit with an error without valid permissions' do
          stub(repository).readable_by?(ssh_public_key) { false }
          dont_allow(manager).upload_pack!
          with_repo_verb :upload do
            expect { SmegHead::Shell::Manager.start [ssh_public_key.id.to_s] }.to exit_sh_manager
          end
        end

      end

      describe 'receive-pack' do

        it 'should perform a top level writeable check' do
          stub(manager).receive_pack!
          mock(repository).writeable_by?(ssh_public_key) { true }
          with_repo_verb :receive do
            SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
          end
        end

        it 'should execute the command if the given permissions exist' do
          stub(repository).writeable_by?(ssh_public_key) { true }
          mock(manager).receive_pack!
          with_repo_verb :receive do
            SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
          end
        end

        it 'should exit with an error without valid permissions' do
          stub(repository).writeable_by?(ssh_public_key) { false }
          dont_allow(manager).receive_pack!
          with_repo_verb :receive do
            expect { SmegHead::Shell::Manager.start [ssh_public_key.id.to_s] }.to exit_sh_manager
          end
        end

      end

    end

    describe 'setting up the environment' do

      it 'should correctly send some information details' do
        called = false
        stub(manager).receive_pack! do
          called = true
          ENV['SH_CURRENT_USER_ID'].should          == ssh_public_key.owner_id.to_s
          ENV['SH_ORIGINAL_REPOSITORY_PATH'].should == "#{repository.clone_path}.git"
          ENV['SH_REPOSITORY_IDENTIFIER'].should    == repository.identifier
        end
        with_repo_verb :receive do
          SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
        end
        called.should be_true
      end

      it 'should correctly set up a temporary drb server' do
        called = false
        stub(manager).receive_pack! do
          called = true
          ENV['SH_DRB_SERVER'].should be_present
        end
        with_repo_verb :receive do
          SmegHead::Shell::Manager.start [ssh_public_key.id.to_s]
        end
        called.should be_true
      end

    end

  end

  private

  def with_repo_verb(verb)
    with_environment 'SSH_ORIGINAL_COMMAND' => "git #{verb}-pack #{repository.clone_path}.git" do
      yield if block_given?
    end
  end

end
