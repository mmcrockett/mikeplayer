require 'test_helper'

class SettingsTest < Minitest::Test
  describe 'settings' do
    let(:home) { File.join('', 'tmp') }
    let(:sdir) { File.join(home, MikePlayer::Settings::SETTINGS_DIRECTORY) }

    before do
      Dir.delete(sdir) if Dir.exist?(sdir)
    end

    it 'creates a settings directory' do
      MikePlayer::Settings.new(home: home)
      assert(Dir.exist?(sdir))
    end
  end
end
