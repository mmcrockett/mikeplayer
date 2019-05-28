require 'test_helper'

class MikePlayerTest < Minitest::Test
  describe 'mikeplayer' do
    it 'has a version' do
      assert(MikePlayer::VERSION)
    end
  end
end
