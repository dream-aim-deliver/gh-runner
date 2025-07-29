Vagrant.configure("2") do |config|
  # Base Ubuntu image
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_version = ">= 0"
  config.ssh.insert_key = false

  # Allow external override of number of runners
  required_env_vars = ['RUNNER_COUNT', 'REPO_URL', 'RUNNER_LABELS', 'GH_ORG_PAT', 'ORG_NAME', 'RUNNER_VERSION']

  missing_vars = required_env_vars.select { |var| ENV[var].to_s.empty? }

  if missing_vars.any?
    abort "❌ Missing required environment variables: #{missing_vars.join(', ')}. Please set them before running Vagrant."
  end

  count = (ENV['RUNNER_COUNT']).to_i

  (1..count).each do |i|
    config.vm.define "gh-runner-#{i}" do |node|
      node.vm.hostname = "gh-runner-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"

      # Provider configuration
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 4096
        vb.cpus = 2
        vb.name = "gh-runner-#{i}"
      end

      # Provision with initialization script triggered at first boot
      node.vm.provision "shell", name: "initialize runner", path: "init-runner.sh", env: { "REPO_URL" => ENV["REPO_URL"], "RUNNER_LABELS" => ENV["RUNNER_LABELS"], "GH_ORG_PAT" => ENV["GH_ORG_PAT"], "ORG_NAME" => ENV["ORG_NAME"], "RUNNER_INDEX" => i.to_s, "RUNNER_VERSION" => ENV["RUNNER_VERSION"] }
    end
  end
end

