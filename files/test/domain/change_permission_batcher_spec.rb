require 'rspec'

require_relative '../../lib/change_permissions_batcher'

describe 'change permissions batcher' do
	describe 'fetching elements' do
		it 'should retrieve the first n element when asked for next n the first time' do
			batcher = Files::ChangePermissionsBatcher.new [1, 2, 3, 4, 5, 6]
			batcher.next(3).should eql [4, 5, 6]
		end
		it 'should retrieve the following n elements when asked for next n the second time' do
			batcher = Files::ChangePermissionsBatcher.new [1, 2, 3, 4, 5, 6]
			batcher.next(3)
			batcher.next(3).should eql [1, 2, 3]
		end
		it 'should retrieve the remaining elements when there are no n' do
			batcher = Files::ChangePermissionsBatcher.new [1, 2, 3, 4, 5]
			batcher.next(3)
			batcher.next(3).should eql [1, 2]
		end
	end
	describe 'has elements' do
		it 'return false if there are no more elements' do
			batcher = Files::ChangePermissionsBatcher.new [1, 2, 3, 4, 5, 6]
			batcher.hasElements?.should be_true
		end
		it 'return true if there are elements' do
			batcher = Files::ChangePermissionsBatcher.new [1, 2, 3, 4, 5, 6]
			batcher.next 6
			batcher.hasElements?.should be_false
		end
	end
end