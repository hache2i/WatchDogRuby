require 'rspec'
require_relative '../../lib/files'

describe 'Files' do
	it 'to string' do
		files = Files::Files.new
		filesArr = []
		filesArr << Files::DriveFile.new('id1', 'title1', [])
		filesArr << Files::DriveFile.new('id2', 'title2', [])
		files.addAll filesArr
		files.to_s.should == 'id1,id2'
	end
end