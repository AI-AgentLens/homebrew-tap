cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2348"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2348/agentshield_0.2.2348_darwin_amd64.tar.gz"
      sha256 "4a969998bb5e16e5bb2763ccf504119fbf6653f6c8b9bb2a0a01184ad5c6d2d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2348/agentshield_0.2.2348_darwin_arm64.tar.gz"
      sha256 "afb3094a2033b3ebb45f7f978aceb69c03da24425ece5cd75ce711a291ac1fce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2348/agentshield_0.2.2348_linux_amd64.tar.gz"
      sha256 "b24b55fe90dc5750be0ffc29d5aa0b37a865982c830aa6839f85d0f10a4bb376"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2348/agentshield_0.2.2348_linux_arm64.tar.gz"
      sha256 "6c2cf48ebd3646f770359fed73592b81dbc239bd2405ec2794f863771a04e382"
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
