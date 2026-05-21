cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1056"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1056/agentshield_0.2.1056_darwin_amd64.tar.gz"
      sha256 "b2d9b56fc6d888def69edd757cfe490b0794837221a3b6e75b62889b06ad12bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1056/agentshield_0.2.1056_darwin_arm64.tar.gz"
      sha256 "5a63cfa9427af5b4fc544431b195dcba44e082d2bbd801ebf408ba3e0fe942d7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1056/agentshield_0.2.1056_linux_amd64.tar.gz"
      sha256 "c4f3dc4c1e8f776d5a3ca7e884cf89b27f4d74ea072fcf634e3cdf7371f53314"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1056/agentshield_0.2.1056_linux_arm64.tar.gz"
      sha256 "43e7c7484567ad780750a6490853af7794873af0eb74b4dd60e7c1663e597b6b"
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
