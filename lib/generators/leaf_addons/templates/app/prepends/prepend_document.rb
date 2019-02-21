# inserted by LeafAddons - Coversheet generator
# Prepend for Hydra::Derivatives::Processors::Document

module PrependDocument
  # override to check converted_file for a nil value
  def convert_to_format
    conv = converted_file
    return if conv.empty?
    if directives.fetch(:format) == 'jpg'
      Hydra::Derivatives::Processors::Image.new(conv, directives).process
    else
      # override to pass the file name, and not File.read(converted_file)
      output_file_service.call(conv, directives)
    end
  end

  def convert_to(format)
    self.class.encode(source_path, format, Hydra::Derivatives.temp_file_base)
    File.join(Hydra::Derivatives.temp_file_base, [File.basename(source_path, ".*"), format].join('.'))
  # override to rescue from soffice conversion errors and kill the process
  rescue StandardError => e
    Rails.logger.error(e)
    grep = `ps aux | grep -i  "#{source_path}" | grep -v grep`
    pid = grep.gsub('  ', ' ').split(' ')[1].to_i unless grep.blank?
    if pid.blank?
      Rails.logger.error("Couldn't get the soffice process pid for #{source_path}")
    else
      Rails.logger.error("Killing process pid: #{pid}")
      Process.kill('KILL', pid) unless pid.blank?
    end
    return '' # sets converted to empty string, avoids TypeError upstream
  end
end
