require 'rspec'
require_relative '../../lib/files_to_change'

describe 'Files To Change' do
	it 'unmarshal' do
		files = Files::FilesToChange.unmarshall('mail1@ideasbrillantes.org#id1,id2&mail2@ideasbrillantes.org#id3,id4')
		files[0].getEmail.should == 'mail1@ideasbrillantes.org'
		files[0].getFiles[0].should == 'id1'
		files[0].getFiles[1].should == 'id2'
		files[1].getEmail.should == 'mail2@ideasbrillantes.org'
		files[1].getFiles[0].should == 'id3'
		files[1].getFiles[1].should == 'id4'
	end
end