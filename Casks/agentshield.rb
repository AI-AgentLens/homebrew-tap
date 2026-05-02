cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.852"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.852/agentshield_0.2.852_darwin_amd64.tar.gz"
      sha256 "14d462f127728f73c76b77cd116b472e4b6eb83f02288b5bdf9dc3605e5a96ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.852/agentshield_0.2.852_darwin_arm64.tar.gz"
      sha256 "bf97a46b71a0ecad79fa9d67c2cf13b01460d0782a039258b20935b1e13e61e3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.852/agentshield_0.2.852_linux_amd64.tar.gz"
      sha256 "9410a1c068494deee9a8bc52e9e64e3d2fd8c876a5b15a2ca283e35326ae6608"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.852/agentshield_0.2.852_linux_arm64.tar.gz"
      sha256 "3f6d9ff2045f9f687da1f2e760474a98be0e123ccf69dfab628f0ea7144c9cc6"
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
