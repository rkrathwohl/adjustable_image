module Paperclip
  class ForceActualFormatProcessor < Processor

    def make
      if actual_file_format.present? && current_file_extension.present? && actual_file_format != current_file_extension
        convert("\"#{current_file_name}\" \"#{destination_path}\"", source: current_file_name, dest: destination_path)

        if attachment.present?
          update_attachment_with_new_file_data
        end

        destination
      else
        @file
      end
    end

    private

    def update_attachment_with_new_file_data
      new_content_type = MIME::Types.type_for(destination_path).first.try(:content_type)

      attachment.instance_write(:file_name, new_file_name(attachment.original_filename))
      attachment.instance_write(:content_type, new_content_type)
      attachment.instance_write(:file_size, destination.size)
    end

    def new_file_name(original_filename)
      filename = original_filename.strip.gsub(/#{current_file_extension}\z/, actual_file_format)

      if (filename !~ /#{actual_file_format}/)
        if (dot_index = filename.rindex('.'))
          filename.insert(dot_index + 1, actual_file_format)
        else
          filename << ".#{actual_file_format}"
        end
      end

      filename
    end

    def current_file_name
      @current_file_name ||= "#{File.expand_path(@file.path)}[0]"
    end

    def actual_file_format
      @actual_file_format ||= identify("-format %m :file", file: current_file_name).to_s.downcase.strip
    end

    def current_file_extension
      @current_file_extension ||= identify("-format %e :file", file: current_file_name).to_s.downcase.strip
    end

    def destination
      unless @temp_destination_file
        @temp_destination_file = Tempfile.new(path_for_temp_file_with_actual_format)
        @temp_destination_file.binmode
      end

      @temp_destination_file
    end

    def destination_path
      @destination_path ||= File.expand_path(destination.path)
    end

    def path_for_temp_file_with_actual_format
      [File.basename(@file.path, current_file_extension), ".#{actual_file_format}"]
    end
  end
end
