cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1627"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1627/agentshield_0.2.1627_darwin_amd64.tar.gz"
      sha256 "4d8488b19cb0d79b862ff5c401876a2a3586febdb6cdbaa5f4e829f2a8299485"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1627/agentshield_0.2.1627_darwin_arm64.tar.gz"
      sha256 "1858cd768c3d04972d3a10ba0ed1014d74c0003fb18bcdbb445b7b92df274f99"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1627/agentshield_0.2.1627_linux_amd64.tar.gz"
      sha256 "9b9fe53357b8fef953f75e3bca18aa7155a93643cb27a713043d23a800ceb318"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1627/agentshield_0.2.1627_linux_arm64.tar.gz"
      sha256 "568ae8eff0facddec8868d3ee35da0d46997b200e23e4c328372a75749456ea7"
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
