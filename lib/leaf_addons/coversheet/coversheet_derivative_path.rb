module LeafAddons
  class CoversheetDerivativePath < Hyrax::DerivativePath
    # Override destination name to add service_file
    def extension
      case destination_name
      when 'thumbnail'
        ".#{MIME::Types.type_for('jpg').first.extensions.first}"
      when 'service_file'
        ".#{MIME::Types.type_for('pdf').first.extensions.first}"
      else
        ".#{destination_name}"
      end
    end
  end
end
