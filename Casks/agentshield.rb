cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.929"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.929/agentshield_0.2.929_darwin_amd64.tar.gz"
      sha256 "a62e0e8b2647f71cbf22bdbcb35fdeffea22a4cbd949869f40e89ddb7e276f60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.929/agentshield_0.2.929_darwin_arm64.tar.gz"
      sha256 "2fc37b62ee96f3536335e7313803985a69807fd4357493935da68ad86e7d125a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.929/agentshield_0.2.929_linux_amd64.tar.gz"
      sha256 "46e808e34347c362832872c0cc034f82ee447e32114bc875f5c731b876afcc9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.929/agentshield_0.2.929_linux_arm64.tar.gz"
      sha256 "7de93febef5a764c6166898574412c19df246cb4d3d31272b50ac6a20b49aa43"
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
