cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1100"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1100/agentshield_0.2.1100_darwin_amd64.tar.gz"
      sha256 "257ed2ecd15780e85fd0b225ebb0b327affd14a13a82454516b495c591f52bd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1100/agentshield_0.2.1100_darwin_arm64.tar.gz"
      sha256 "d74c6f9d0bbdfb096a575071e0bb6ebe6488e1e1e0f483903e369c4b20d03b9a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1100/agentshield_0.2.1100_linux_amd64.tar.gz"
      sha256 "c57fc60b67479d41329b30e01cbde70ad9610c3ff2e21b0803bcdee191daf0f8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1100/agentshield_0.2.1100_linux_arm64.tar.gz"
      sha256 "db5e532c04d07927e56ce37bd054ec1a3804e6f613b7eba6e8c6b0190f5c81a8"
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
