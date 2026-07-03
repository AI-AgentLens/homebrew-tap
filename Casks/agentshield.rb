cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1539"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1539/agentshield_0.2.1539_darwin_amd64.tar.gz"
      sha256 "168d437019fb5cde2b28ad48898ab107111f5db20acac2a2ef9024fd93879ff8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1539/agentshield_0.2.1539_darwin_arm64.tar.gz"
      sha256 "43544f140cf7f70f84fcc930d7b7f54c36a6ace2817c5287735d1905227b8f75"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1539/agentshield_0.2.1539_linux_amd64.tar.gz"
      sha256 "5cc8d9ecc396ccf1bbb80b5b0e73663137bb98426d9af7b5b4161f003eeaecf4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1539/agentshield_0.2.1539_linux_arm64.tar.gz"
      sha256 "1eff0a8dfa8882c306748a0cf053e220357917ea8cf2e723ef5f16a3daf78652"
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
