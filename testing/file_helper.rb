require 'tmpdir'

module ReportBuilder
  module FileHelper

    class << self

      def created_directories
        @created_directories ||= []
      end

      def create_directory
        new_dir = Dir::mktmpdir
        created_directories << new_dir

        new_dir
      end

      def clear_created_directories
        created_directories.each do |directory_path|
          FileUtils.remove_entry(directory_path) if File.exist?(directory_path)
        end
      end

    end

  end
end
