cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2271"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2271/agentshield_0.2.2271_darwin_amd64.tar.gz"
      sha256 "422c9e8e4f1fa48d24837c497be50e716419174d7eff8519b188c8642aacb25a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2271/agentshield_0.2.2271_darwin_arm64.tar.gz"
      sha256 "6504bba04221f281bcbb16757b0bbb8833463c5ee76523b77374594c08754cd9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2271/agentshield_0.2.2271_linux_amd64.tar.gz"
      sha256 "8df0e9b0bc27cf982500704e9b88af22ee266670d493ffcfea955658e4ade1e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2271/agentshield_0.2.2271_linux_arm64.tar.gz"
      sha256 "b3a82d67ecf2d9d97420299d4b2699dfedabf2029f067aa842237954451b11d9"
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
