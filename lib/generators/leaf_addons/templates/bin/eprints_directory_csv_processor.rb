require 'fileutils'

# Crude script to generate a files csv from an eprints documents directory
# This should be run with a depth of 2
#
# Assumptions:
#   the file structure is document/somedir/xx/xx/xx/xx/doc_no/file
#   xx/xx/xx/xx is the eprintid padded with zeros to 8
#   the hyrax id is the eprints id padded with zeros to 9

if ARGV.empty?
  puts "Please supply the path to the directory containing a directory called 'documents'\n"
  puts "  the file structure should match documents/somedir/xx/xx/xx/xx/doc_no/file\n"
  puts "  where xx/xx/xx/xx is the eprintid padded with zeros to 8\n\n"
  puts "EXAMPLE (supply a path): ruby eprints_directory_csv_processor.rb directory\n"
  puts "EXAMPLE (use current directory): ruby eprints_directory_csv_processor.rb . \n"
elsif Dir.exist? ARGV.first
  base_path = ARGV.first
  base_path = "#{ARGV.first}/" unless ARGV.first.end_with? '/'
  path = File.join(ARGV.first, 'documents')
  if Dir.exist? path
    puts "Processing #{base_path}"

    # Delete the revisions folder - we don't want this
    Dir.glob(File.join(path, '/**/*/')) do |dir|
      FileUtils.rm_r dir if dir.include? 'revisions'
    end

    files_csv = File.open('eprints_directory_csv_processed.csv', 'w')

    # Create a csv with id,folder
    Dir.glob(File.join(path, '/**/*/')) do |folder|
      relative_folder = folder.gsub(base_path, '')
      folders = relative_folder.split('/')
      if folders.length == 6
        id = "0#{folders.slice(2..5).join}"
        files_csv.write("#{id},#{relative_folder}\n")
      end
    end

    puts 'CSV written to eprints_directory_csv_processed.csv'
  else
    puts 'Supplied directory does not contain a documents directory'
  end
else
  puts 'Supplied directory does not exist. Please supply a valide directory path.'
end
