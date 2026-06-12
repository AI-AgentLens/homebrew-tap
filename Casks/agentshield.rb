cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1298"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1298/agentshield_0.2.1298_darwin_amd64.tar.gz"
      sha256 "b19f925d0d821349921865fce90491fb833d7d7fff3f83f9de682857b51c523e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1298/agentshield_0.2.1298_darwin_arm64.tar.gz"
      sha256 "aaa2a5cb8ffa3a6da9cdc2ba8805e93b9a12e72161b382f85b3f1a10aedb1e02"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1298/agentshield_0.2.1298_linux_amd64.tar.gz"
      sha256 "19a62dbf356609f2fff2484c2313033f1e804d2464c815f8f5acac29ac68debf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1298/agentshield_0.2.1298_linux_arm64.tar.gz"
      sha256 "3e3f45b79ecee5311a64e7ce81d5b747ad6f5a080722f79214361b63727cb866"
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
