cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1747"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1747/agentshield_0.2.1747_darwin_amd64.tar.gz"
      sha256 "83e50b6241c53855d865b664cf2cdc05c526880973e75599d4ae19d2313953b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1747/agentshield_0.2.1747_darwin_arm64.tar.gz"
      sha256 "ac7d3f001c0bffbe19d062735d90e308d06f6a0a4ab4b5e0de56d5a2c48b2198"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1747/agentshield_0.2.1747_linux_amd64.tar.gz"
      sha256 "623726ec53e515e3b854674dc8e0277125c0715803e0288fc0fb8c73456015bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1747/agentshield_0.2.1747_linux_arm64.tar.gz"
      sha256 "d73a3e2f6a5d2a21afb12c5b43cb0db383f5e56c04e880a40379d717b44fdc07"
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
