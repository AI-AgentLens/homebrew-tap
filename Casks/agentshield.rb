cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2363"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2363/agentshield_0.2.2363_darwin_amd64.tar.gz"
      sha256 "57a2748f0d4d094be528aaf69c09a21dd2c3447a8aebd5451f9c03cea26dc747"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2363/agentshield_0.2.2363_darwin_arm64.tar.gz"
      sha256 "bb78c1d7344998edbf4662d27989540504c13bba77ceedd917dfe23550193e7d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2363/agentshield_0.2.2363_linux_amd64.tar.gz"
      sha256 "9b57d20117bf79cebe5db82e8ed272a0120884aa543731d574eeda29c40dd4ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2363/agentshield_0.2.2363_linux_arm64.tar.gz"
      sha256 "9edbc3441a0a2e7c155a8a7dded2a1f05ae9235a0a5c6b8cf22ea0fd8389a183"
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
