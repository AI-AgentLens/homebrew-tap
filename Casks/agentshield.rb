cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.347"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.347/agentshield_0.2.347_darwin_amd64.tar.gz"
      sha256 "536303e3d454e33b4b9d47aa3e8a600709d44094d2e6c99157dd17cf3d482264"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.347/agentshield_0.2.347_darwin_arm64.tar.gz"
      sha256 "3cca54a118b88ee55eabe1dc140ee634664cc9a33848515c127e2dab04f00fd5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.347/agentshield_0.2.347_linux_amd64.tar.gz"
      sha256 "daa67da1489512f3d5604a2328d38f9bc65117244db5946b7e6dbf1f83f31a10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.347/agentshield_0.2.347_linux_arm64.tar.gz"
      sha256 "2709b65be21a19e59bea1b64e1c5be0b1cc8dc66882dd08e6538f63ec48d1769"
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
