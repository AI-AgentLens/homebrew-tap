cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1631"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1631/agentshield_0.2.1631_darwin_amd64.tar.gz"
      sha256 "be70667effba2b67c2c7fdfd751bd28c80090e2ffc6fe39bcda8897083ac66ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1631/agentshield_0.2.1631_darwin_arm64.tar.gz"
      sha256 "59b2ee3640ba81705f45fb9ae1c35ea07f90701950cb4d300aedd816d46f248e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1631/agentshield_0.2.1631_linux_amd64.tar.gz"
      sha256 "d70d3c453f6648f72e70f63cc577b7d877abfd94279e148a4b7aae246a870c36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1631/agentshield_0.2.1631_linux_arm64.tar.gz"
      sha256 "b7199836360be1e3991ec4b1a6640a11f3ad406b527588c53ecd1c2056eb98d5"
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
