cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.516"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.516/agentshield_0.2.516_darwin_amd64.tar.gz"
      sha256 "615bf27989b43b3bd581fae5a3cce9904af6f2f2c15bb5acdc70a23c9ffd456c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.516/agentshield_0.2.516_darwin_arm64.tar.gz"
      sha256 "e6795ea68a77761a6e0852d7adcad550de25d3a0a31197095cd56479934d0e5c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.516/agentshield_0.2.516_linux_amd64.tar.gz"
      sha256 "e7e8173ce89e5e4e8e2ed8763cea9a5e6fc808d43c2bbb3e78e1eb6b413f903d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.516/agentshield_0.2.516_linux_arm64.tar.gz"
      sha256 "d0bc6be32c3d755eb1284cada934a445ab0532c1d7d21e34d2d61b02c3ff939a"
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
