cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2226"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2226/agentshield_0.2.2226_darwin_amd64.tar.gz"
      sha256 "aff0fd9ea2f51221f85a383fef3f99a5ba6bdda95b63099b706280e667aa7cfb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2226/agentshield_0.2.2226_darwin_arm64.tar.gz"
      sha256 "beed8d62921c759f6127634c11ee44e878cd09bc2cae339911e8f82aed2993d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2226/agentshield_0.2.2226_linux_amd64.tar.gz"
      sha256 "d3fe25f90a7bb8dba15cc62409d79fef0c299b2841f7bfeb4b6a5149f131e8d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2226/agentshield_0.2.2226_linux_arm64.tar.gz"
      sha256 "a3b9d2c0eb890ee33b4c1dca2f260d864bf2f7332a40e2049c9fcce0f26fd746"
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
