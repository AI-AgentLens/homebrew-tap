cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1073"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1073/agentshield_0.2.1073_darwin_amd64.tar.gz"
      sha256 "2074c3528e54d519fcb08cf69d00d5ba4d7d5bebc78af5ece84a559211b8ea5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1073/agentshield_0.2.1073_darwin_arm64.tar.gz"
      sha256 "cff715ba3eea29905c5ad27cd228ae15ed541a18783ab16a7338ec2cfef3af9b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1073/agentshield_0.2.1073_linux_amd64.tar.gz"
      sha256 "a04b6cb9ac6cc9da75d213ec56bda78f0db83747eae4f179f945d4e48ea4eab2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1073/agentshield_0.2.1073_linux_arm64.tar.gz"
      sha256 "ed244338c2bd9821cc27d88862265492172bf24d386fd57ad9b4e91566405001"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
