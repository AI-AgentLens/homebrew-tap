cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2032"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2032/agentshield_0.2.2032_darwin_amd64.tar.gz"
      sha256 "3aadb6bfb87dc664380d479a9e7202269144a9b6f6fd2cd75be263e2555be742"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2032/agentshield_0.2.2032_darwin_arm64.tar.gz"
      sha256 "c9ebc551083e646913ca7489817268a87e41bac0e4d2eaf419c08eff609f5db5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2032/agentshield_0.2.2032_linux_amd64.tar.gz"
      sha256 "8deb4f237f236f3d804edb1fc420fbfbd66beb815576d4f369a1d30e30888d79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2032/agentshield_0.2.2032_linux_arm64.tar.gz"
      sha256 "1c6e8b72f903d77b947001d1f41bc4a9af6805443e96e7edd5fbaa825f64442b"
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
