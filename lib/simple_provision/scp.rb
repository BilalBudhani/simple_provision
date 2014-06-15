module SimpleProvision
  class SCP
    FILENAME = "simpro.tar.gz"

    def initialize(server, opts)
      @server, @opts = server, opts
    end

    def to_server
      check_executable_permissions
      create_local_archive
      scp_files_to_server
      extract_remote_archive
      remove_remote_archive
      remove_local_archive
    end

    private

    def check_executable_permissions
      @opts.fetch(:scripts).each do |file|
        raise "The script #{file} is not executable." unless File.executable?(file)
      end
    end

    def create_local_archive
      files = @opts[:files] || []
      scripts = @opts[:scripts] || []
      includes = files + scripts

      if includes.empty?
        raise "Both files and scripts are empty. You should provide some"
      end

      system("mkdir tmp")
      system("mkdir tmp/files")
      system("mkdir tmp/scripts")
      files.each do |f|
        system("cp servers/#{f} tmp/files/")
      end
      scripts.each do |f|
        system("cp servers/#{f} tmp/scripts/")
      end

      system("cd tmp && tar -czf #{FILENAME} files/ scripts/")
    end

    def scp_files_to_server
      @server.scp("tmp/#{FILENAME}", ".")
    end

    def extract_remote_archive
      @server.ssh("tar -xzf #{FILENAME}")
    end

    def remove_remote_archive
      @server.ssh("rm #{FILENAME}")
    end

    def remove_local_archive
      `rm -rf tmp`
    end
  end
end
