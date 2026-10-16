cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2448"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2448/agentshield_0.2.2448_darwin_amd64.tar.gz"
      sha256 "ae37966c8ad143a84ab49923121d1734ea2e65620fcf4e90ac0c37f66dabc2b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2448/agentshield_0.2.2448_darwin_arm64.tar.gz"
      sha256 "75d80d34593e2236b275122ea4f9c902759257d4015e59ac5e5fa8f1f764be31"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2448/agentshield_0.2.2448_linux_amd64.tar.gz"
      sha256 "09df29c61bfe2c6c5acaaacfc12c38b19949bcb2470028291c8be8eeb1570834"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2448/agentshield_0.2.2448_linux_arm64.tar.gz"
      sha256 "4dbcdb4f66c51ca1c898d6b6eecb5ed9659dadebe1cc5491f15e4c6179933c65"
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
