cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2459"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2459/agentshield_0.2.2459_darwin_amd64.tar.gz"
      sha256 "9aa7d2c086f5d4fb5fe68629506fb02f72ce2705d7fe1b55ba2288759391add9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2459/agentshield_0.2.2459_darwin_arm64.tar.gz"
      sha256 "6930627983b2f392f8155a09f697d30baec6aa227239007b647fcf878f32bec2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2459/agentshield_0.2.2459_linux_amd64.tar.gz"
      sha256 "0622bc4a3ce0ec4416143dca21f2a27637a2410632d3e087d0597f8e3eee4a7d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2459/agentshield_0.2.2459_linux_arm64.tar.gz"
      sha256 "d22dbe357df8a8890efc493ac0c0bd932c884dbf6f4141a65d0bf142c4cad485"
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
