cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1772"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1772/agentshield_0.2.1772_darwin_amd64.tar.gz"
      sha256 "986e3bd0627d83190fdef31cf2874bb36a584a2ef1639cb4f6f60b4e3d2fbff6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1772/agentshield_0.2.1772_darwin_arm64.tar.gz"
      sha256 "d4d17407a701265c8400e145da5a5c225d43123b7de3a0895989510531e92a53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1772/agentshield_0.2.1772_linux_amd64.tar.gz"
      sha256 "d4ebba82392f6a5c7d55f4faf2ba72c756bd1aee241c6b5a4c6199001c9eedf8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1772/agentshield_0.2.1772_linux_arm64.tar.gz"
      sha256 "9a27f5a587f0163093a5e8d834992ed3c2906f0f92d01510656d018381344225"
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
