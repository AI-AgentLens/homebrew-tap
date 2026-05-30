cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1161"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1161/agentshield_0.2.1161_darwin_amd64.tar.gz"
      sha256 "6daca67b60ac69d8640a8e6d99996e4a1bed37d7cab18f344c1e7436ba0c4099"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1161/agentshield_0.2.1161_darwin_arm64.tar.gz"
      sha256 "c78b77bbfc1eca1d46a7b833e07bdb657b1dba56ba58afb0908f10c053508d83"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1161/agentshield_0.2.1161_linux_amd64.tar.gz"
      sha256 "7ac643a7b20524b8e62c06c8488d48b2eab65bb8c223180a03124411afdbef88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1161/agentshield_0.2.1161_linux_arm64.tar.gz"
      sha256 "337717472eef09262ef29038fcd747c8f7082cb11da045a6a1624361a3503631"
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
