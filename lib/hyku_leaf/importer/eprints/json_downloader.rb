# frozen_string_literal: true

module HykuLeaf
  module Importer
    module Eprints
      module JsonDownloader
        include Enumerable

        # Download each file listed in hash['documents']
        #
        # @param eprint [Hash] a hash of the eprint document metadata
        # @return [String] the directory containing the downloaded files
        def download(eprint_documents, eprintid)
          dir = make_eprint_directory(eprintid.to_s)
          eprint_documents.each do |doc|
            process_eprint(dir, doc)
          end
        end

        # Process an eprint document
        #
        # @param dir [String] the directory to download files into
        # @param doc [Hash] document hash
        def process_eprint(dir, doc)
          download_url = setup_download_url(doc)
          docid = docid(doc)
          visibility = visibility(doc)
          return if docid == 'skipme'
          path = setup_download_path(dir, docid, download_url)
          do_download(download_url, path)
          if verify_checksum(doc['files'].first['hash'], path)
            write_to_downloads_csv(make_identifier(doc['eprintid']), path.split('/')[-2])
            write_to_files_list_csv(make_identifier(doc['eprintid']), path.split('/')[-1], visibility)
          else
            warn "Checksum mismatch for #{path}. File not added."
            Rails.logger.error "Checksum mismatch for #{path}. File not added."
          end
        end

        # Set the docid
        #
        # @param doc [Hash] the document hash
        # @return [String] the docid
        def docid(doc)
          docid = doc['docid']
          if doc['relation'].present?
            doc['relation'].each do |rel|
              if rel['type'].include? 'isIndexCodesVersionOf'
                docid = rel['uri'].split('/')[-1]
              elsif rel['type'].include? 'issmallThumbnailVersionOf'
                docid = 'skipme'
              end
            end
          end
          docid
        end

        # Set the visibility
        #
        # @param doc [Hash] the document hash
        # @return [String] the visibility
        def visibility(doc)
          visibility = nil
          visibility = 'restricted' if doc['security'].present? && doc['security'] != 'public'
          if doc['relation'].present?
            doc['relation'].each do |rel|
              if rel['type'].include? 'isIndexCodesVersionOf'
                visibility = 'restricted'
              end
            end
          end
          visibility
        end

        # Verify the supplied md5 checksum value by computing the checksum of the given file
        #
        # @param md5 [String] md5 checksum
        # @param path [String] path to the file
        # @return [Boolean]
        def verify_checksum(md5, path)
          checksum = Digest::MD5.new
          IO.foreach(path) { |x| checksum << x }
          checksum.hexdigest == md5
        end

        # Write a line to the downloaded_files.csv
        #
        # @param id [String] id of the item in fedora
        # @param filename [String] downloaded flename
        # @param visibility [String] visibility (default=nil)
        def write_to_files_list_csv(id, filename, visibility = nil)
          downloads_csv = File.join(@downloads, 'downloaded_files.csv')
          line = "#{id},#{filename},"
          line += visibility.to_s unless visibility.nil?
          line += "\n"
          if File.exist?(downloads_csv) && !File.read(downloads_csv).include?(line)
            File.open(downloads_csv, 'a+') { |f| f << line }
          else
            File.open(downloads_csv, 'w') { |f| f << line }
          end
        end

        # Write a line to the import_files.csv
        #
        # @param id [String] id of the item in fedora
        # @param folder [String] folder to import
        def write_to_downloads_csv(id, folder)
          import_files_csv = File.join(@downloads, 'import_files.csv')
          line = "#{id},#{folder}\n"

          if File.exist?(import_files_csv) && !File.read(import_files_csv).include?(line)
            File.open(import_files_csv, 'a+') { |f| f << line }
          else
            File.open(import_files_csv, 'w') { |f| f << line }
          end
        end

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

        # rubocop:disable Style/RescueStandardError

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
        rescue
          warn "Something went wrong when attempting to download #{download} to #{path} (#{$ERROR_INFO.message})"
          Rails.logger.warn "Something went wrong when attempting to download #{download} to #{path} (#{$ERROR_INFO.message})"
        end

        # rubocop:enable Style/RescueStandardError

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
    end
  end
end
