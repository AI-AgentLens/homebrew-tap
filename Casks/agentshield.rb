cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1206"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1206/agentshield_0.2.1206_darwin_amd64.tar.gz"
      sha256 "9154857d74e2e9918ca1faf4a5e7bcc5d3097765d2260cd2852dc8b16d965fb5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1206/agentshield_0.2.1206_darwin_arm64.tar.gz"
      sha256 "de6b1fd7cd5ea30a1916b45fce33ccb9c7df535d75f5a88d13f18ad9a82b1b2c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1206/agentshield_0.2.1206_linux_amd64.tar.gz"
      sha256 "e2e6983e1e0b731c901051db644a9373667dc8a0acd10e9b3f979aaa30a44eec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1206/agentshield_0.2.1206_linux_arm64.tar.gz"
      sha256 "53f812d91b90e9afe3989c400ca3942a30699fe68a2e2a97e3e98cf109862eb7"
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
