cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1961"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1961/agentshield_0.2.1961_darwin_amd64.tar.gz"
      sha256 "9ff46b9a7fb833b9902a2291c0e62001a2d3dc9279f76efc275046d5925ac3d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1961/agentshield_0.2.1961_darwin_arm64.tar.gz"
      sha256 "d5a063f47a4885afc566cf953c4366d533ea198b9e7e96f23c8f9271389c171d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1961/agentshield_0.2.1961_linux_amd64.tar.gz"
      sha256 "a6c5adb379a07368d84e6b7a3c8e28b751d34e1acb5e3c45e8874085a1365d86"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1961/agentshield_0.2.1961_linux_arm64.tar.gz"
      sha256 "2e85b760eb942a282f8785734b10c64e5c224871dd5c440a2f179bcd6267c013"
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
