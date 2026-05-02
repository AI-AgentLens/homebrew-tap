cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.850"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.850/agentshield_0.2.850_darwin_amd64.tar.gz"
      sha256 "00652c5e18e71a432780c1658a5e487afa4bd4a770a2e50bc0bee01600deeff8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.850/agentshield_0.2.850_darwin_arm64.tar.gz"
      sha256 "0f5cfc0b1bec6cf94615bcf66c69332d524da3c8cef094398675f9efdc19d5f8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.850/agentshield_0.2.850_linux_amd64.tar.gz"
      sha256 "4384975cbfafbfa5e616786db20b5de78f662a69f053b17dedfbd01071015b3f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.850/agentshield_0.2.850_linux_arm64.tar.gz"
      sha256 "d84d03e7b69ff8e431034c1e6911bcf7c26e6f00e992f295d1b2a4e5e148e12d"
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
