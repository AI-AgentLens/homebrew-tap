cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2091"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2091/agentshield_0.2.2091_darwin_amd64.tar.gz"
      sha256 "5f32520153e2f97f5b62b75dd7d8ad0a51069dfb70c70bf04dedfcdaa15076e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2091/agentshield_0.2.2091_darwin_arm64.tar.gz"
      sha256 "f2277424804a633f93429330734d5300b8dec648a90a78b7a011bf37e0b54902"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2091/agentshield_0.2.2091_linux_amd64.tar.gz"
      sha256 "12b210a36aa584f811fc54db0a2fa795994b9fa2fcfdfb9785425d2b7bac1158"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2091/agentshield_0.2.2091_linux_arm64.tar.gz"
      sha256 "fb90a08bc0a7e83847a0c42fe0365b4a5b110c4d36962ebcc8ede3aabdd58334"
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
