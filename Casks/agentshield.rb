cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.268"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.268/agentshield_0.2.268_darwin_amd64.tar.gz"
      sha256 "839378ac7e7708ad63396aa37de72ba5c0801250d1776e7689c34f4d302371fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.268/agentshield_0.2.268_darwin_arm64.tar.gz"
      sha256 "2e4094132f2c11351eb49b34194d41ae680656d0d644479575d88e50e7ff145b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.268/agentshield_0.2.268_linux_amd64.tar.gz"
      sha256 "bedbf23564927c39c94b8fc83110e9049a7b61a8721bf76dad8b19b442e2551a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.268/agentshield_0.2.268_linux_arm64.tar.gz"
      sha256 "d8fea4e0dc1879f4152eb50568ec4e199c4fc4a3e6978c4feb6cfdb2c64df045"
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
