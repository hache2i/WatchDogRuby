require 'rspec'

require_relative '../../lib/drive_file'

describe 'DriveFile' do
	it 'should have a string with the names of its owners' do
		file = Files::DriveFile.new('id', 'file title', ['Juan Perez', 'Miguel Dominguez'])
		file.owners.should == 'Juan Perez, Miguel Dominguez'
	end
end