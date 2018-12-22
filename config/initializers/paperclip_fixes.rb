require 'paperclip'

module VerifyMimeType
  # Open remote file using underlying OS and check if its mime type matches what Paperclip
  # thinks it is. Sometimes images uploaded from the web or mobile are determined to have
  # `application/octet-stream` as their content type, causing silent validation errors that
  # break counter caches.
  def verify_mime_type(instance, attachment_name='attachment')
    interpolated_mime_type = instance.send("#{attachment_name}_content_type".to_sym)
    return interpolated_mime_type unless instance.s3_url
    actual_mime_type = nil
    begin
      Timeout::timeout(3) do
        retries ||= 0

        if interpolated_mime_type == 'application/octet-stream'
          temp_file = URI.parse(instance.s3_url)
          attachment_path = temp_file.path
          # temp_file && temp_file.close
          actual_mime_type = `file --b --mime-type '#{attachment_path}'`.strip
          p '#########'
          p actual_mime_type
          p '#########'
        else
          actual_mime_type = interpolated_mime_type
        end
      end
    rescue Timeout::Error => e
      if retries < 1
        retries += 1
        retry
      else
        actual_mime_type = interpolated_mime_type
      end
    end

    actual_mime_type
  end
end

Paperclip.class_eval { extend VerifyMimeType }
