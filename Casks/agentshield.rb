cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2341"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2341/agentshield_0.2.2341_darwin_amd64.tar.gz"
      sha256 "c974bafb85e82fccb2ebe7c9d855a6c2807304236f10c49d13d788e04cbb0056"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2341/agentshield_0.2.2341_darwin_arm64.tar.gz"
      sha256 "e470d8adbab0e4e00c8fd877cd8c18ab03c37911f931e2febe271c73c9c6f3f6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2341/agentshield_0.2.2341_linux_amd64.tar.gz"
      sha256 "6d68dbe0d6ca2b747405bff035e9f58801f94bedf1a955883dfb745a358f0a36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2341/agentshield_0.2.2341_linux_arm64.tar.gz"
      sha256 "47b2bb6a6505242292d1dd53c5a15e8f619c5d948b9dca9bbc6e90f7c5fce9a5"
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
