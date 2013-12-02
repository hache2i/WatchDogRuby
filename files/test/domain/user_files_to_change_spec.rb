require 'rspec'
require_relative '../../lib/user_files_to_change'

describe "User files to change" do
	it "is created for an email and it is accessible" do
		filesToChange = Files::UserFilesToChange.new "juan@bla.es"
		filesToChange.getEmail.should eql "juan@bla.es"
	end
	it "has no files when created" do
		filesToChange = Files::UserFilesToChange.new "juan@bla.es"
		filesToChange.getFiles.should be_empty
	end
	it "it is possible to add a file id" do
		filesToChange = Files::UserFilesToChange.new "juan@bla.es"
		filesToChange.addFile "fileId"
		filesToChange.getFiles.should_not be_empty
	end
	it "it is possible to add a bunch of files" do
		files = ['id1', 'id2', 'id3']
		filesToChange = Files::UserFilesToChange.new "juan@bla.es"
		filesToChange.addFiles files
		filesToChange.getFiles.include?('id1').should be_true
		filesToChange.getFiles.include?('id2').should be_true
		filesToChange.getFiles.include?('id3').should be_true
	end
end