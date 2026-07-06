cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1564"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1564/agentshield_0.2.1564_darwin_amd64.tar.gz"
      sha256 "72bb806f39c3bceb824bf658c78a43138b734206021bea8c027e647e200c024c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1564/agentshield_0.2.1564_darwin_arm64.tar.gz"
      sha256 "b9ae31404ba0b9c12d802d2c0b3256e2d41558fdc6e55e2219d5999d57a4c660"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1564/agentshield_0.2.1564_linux_amd64.tar.gz"
      sha256 "c21659b149c918b2c5e34a4d3efa13ac1f21c21fe5a2c6802bcc56f6f1f23cc3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1564/agentshield_0.2.1564_linux_arm64.tar.gz"
      sha256 "4479f6d7e2b571c37134674e6a09ed7e354b3aa8e786df8af6c982f8a987e61c"
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
