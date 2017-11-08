module HykuLeaf
  module Importer
    module Eprints
      module JsonDownloader
        include Enumerable

        # Download each file listed in hash['documents']
        #
        # @param eprint [Hash] a hash of the eprint document metadata
        # @return [String] the directory containing the downloaded files
        def download(eprint_documents)
          dir = make_eprint_directory(eprint['eprintid'].to_s)
          eprint_documents.each do |doc|
            download_url = setup_download_url(doc)
            # do the if relation thing here
            docid = doc['docid']
            visibility = nil
            if doc['relation'].present?
              doc['relation'].each do | rel |
                if rel['type'].include? 'isIndexCodesVersionOf'
                  docid = rel['uri'].split('/')[-1]
                  visibility = 'restricted'
                end
              end
            end
            path = setup_download_path(dir, docid, download_url)
            next if File.exist? path
            do_download(download_url, path)
            if verify_checksum(doc['hash'], path)
              write_to_csv(make_identifier(doc['eprintid']),path.split('/')[-1],visibility)
            else
              $stderr.puts "\nChecksum mismatch for #{path}. File not added."
              Rails.logger.error "Checksum mismatch for #{path}. File not added."
            end
          end
        end

        private

        # Construct the download url from the document hash
        #
        # @param document [Hash] the eprint document
        # @return [String] download url
        def setup_download_url(document)
          uri = document['uri'].split('/')
          "#{uri[0]}//#{uri[2]}/#{document['eprintid']}/#{document['pos']}/#{document['main']}"
        end

        # Construct the path for the download
        #
        # @param dir [String] the directory
        # @param download [String] the download url
        # @return [String] the download path (including filename to write)
        def setup_download_path(dir, docid, download)
          "#{dir}/#{docid}_#{download.to_s.split('/')[-1]}"
        end

        # Do the download
        #
        # @param download [String] the uri to download
        # @param path [String] the download path
        def do_download(download, path)
          Rails.logger.info "Downloading #{download}"

          require 'open-uri'

          File.open(path, 'wb') do |contents|
            contents << open(download, &:read)
          end
        end

        # Create a directory for the downloaded files
        #
        # @param eprint_id [String] the eprint id
        # @return [String] path to the new directory
        def make_eprint_directory(eprint_id)
          dir = File.join(@downloads, eprint_id)
          Dir.mkdir(dir, 0o770) unless Dir.exist? dir
          File.absolute_path(dir, '')
        end
      end

      def verify_checksum(md5, path)

        checksum = Digest::MD5.new
        IO.foreach(path) {|x| checksum << x }

        if checksum.hexdigest == md5
          true
        else
          false
        end
      end

      def write_to_csv(id,filename,visibility=nil)
        downloads_csv = File.join('downloads.csv', @downloads)

        line =  "#{id},#{filename}"
        line += "#{visibility}" unless visibility.nil?
        line += "\n"
        if File.exist?(downloads_csv)
          downloads_file = File.open(downloads_csv, 'a+')
          downloads_file.write(line)
        else
          downloads_file = File.read(downloads_csv, 'w')
          downloads_file.write(line)
        end
      end

    end
  end
end
