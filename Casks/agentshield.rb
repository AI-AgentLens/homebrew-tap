cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1302"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1302/agentshield_0.2.1302_darwin_amd64.tar.gz"
      sha256 "b4f0234bd3f11ce4b0815a7d1901bd4d87771f25f3d186f9d7739a1bf6ad9500"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1302/agentshield_0.2.1302_darwin_arm64.tar.gz"
      sha256 "92b437c99da10bc8b265cda65ffd6c819b201b469b8da4ef54bff780cdf28a92"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1302/agentshield_0.2.1302_linux_amd64.tar.gz"
      sha256 "fad9a1747fef9a0cf080ea1e997c8473a4b1a95a581051df3b51d93925adfc2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1302/agentshield_0.2.1302_linux_arm64.tar.gz"
      sha256 "7d3b88deee43beafda6134d2a4b059ef8b7d20fd1f932ab81ca168a61f1c3000"
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
