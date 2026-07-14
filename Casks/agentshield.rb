cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1645"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1645/agentshield_0.2.1645_darwin_amd64.tar.gz"
      sha256 "645e9022fbaba98fee49e80585bce20278a1b7dde8a59058963cef520ab87a99"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1645/agentshield_0.2.1645_darwin_arm64.tar.gz"
      sha256 "176281ee3dd3b2f21f8fcc0f1217402fd6128ec82a401bd7e83e040806776b97"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1645/agentshield_0.2.1645_linux_amd64.tar.gz"
      sha256 "2a46ad7bad3e7a3eba3d21ff2afe53f2993171d1d8d4cb444ae7d2b383c7702a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1645/agentshield_0.2.1645_linux_arm64.tar.gz"
      sha256 "43d66981bf95408824261ed0a369709e73447a4f000fe79e41d749b403f7cd2e"
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
