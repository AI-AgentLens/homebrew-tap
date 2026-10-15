cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2433"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2433/agentshield_0.2.2433_darwin_amd64.tar.gz"
      sha256 "f85c343a048c5d949745569ad12015e64ca65c3d204bd2a569b2f0ae101ae46f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2433/agentshield_0.2.2433_darwin_arm64.tar.gz"
      sha256 "bea7072b3ea96c9ca8f9caf2bf0320159ee601924b7e2224458d60df74575ee7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2433/agentshield_0.2.2433_linux_amd64.tar.gz"
      sha256 "06223e9c738517cdb364614630dbb2157ae916797d9edf313d27098dcb2d3543"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2433/agentshield_0.2.2433_linux_arm64.tar.gz"
      sha256 "bb1934c7f71e8dc894245b98770d357bfb9246a5831dced9c9ff421d53410650"
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
