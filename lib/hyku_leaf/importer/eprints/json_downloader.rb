module Importer
  module Eprints
    module JsonDownloader
      include Enumerable

      # Currently Unused

      # Download each file listed in hash['documents']
      #
      # @param eprint [Hash] a hash of the eprint metadata
      # @return [String] the directory containing the downloaded files
      def download(eprint)
        dir = make_eprint_directory(eprint['eprintid'].to_s)
        eprint['documents'].each do |doc|
          download_url = setup_download_url(doc)
          path = setup_download_path(dir, download_url)
          next if File.exist? path
          do_download(download_url, path)
        end
        dir
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
        def setup_download_path(dir, download)
          "#{dir}/#{download.to_s.split('/')[-1]}"
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
          dir = File.join(@directory, eprint_id)
          Dir.mkdir(dir, 0o770) unless Dir.exist? dir
          File.absolute_path(dir, '')
        end
    end
  end
end
