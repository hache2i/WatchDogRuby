require 'rspec'
require_relative '../../lib/files_to_change'

describe 'Files To Change' do
	it 'unmarshal' do
		files = Files::FilesToChange.unmarshall('mail1@ideasbrillantes.org#id1,id2-mail2@ideasbrillantes.org#id3,id4')
		files[0][:mail].should == 'mail1@ideasbrillantes.org'
		files[0][:id].should == 'id1'
		files[1][:mail].should == 'mail1@ideasbrillantes.org'
		files[1][:id].should == 'id2'
		files[2][:mail].should == 'mail2@ideasbrillantes.org'
		files[2][:id].should == 'id3'
		files[3][:mail].should == 'mail2@ideasbrillantes.org'
		files[3][:id].should == 'id4'
	end
end