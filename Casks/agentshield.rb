cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1105"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1105/agentshield_0.2.1105_darwin_amd64.tar.gz"
      sha256 "9e6f1497556156768a0ab2aa6e530e698607b3fa5d86a0854fc82a944801c335"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1105/agentshield_0.2.1105_darwin_arm64.tar.gz"
      sha256 "e861d6ef16be73aa2f38c64150774e8e4c3b1b56c125571495d6dff8b8d959de"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1105/agentshield_0.2.1105_linux_amd64.tar.gz"
      sha256 "b66ea33655195a5bff5bd592471384da72185c24bac44545d32576f664c50537"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1105/agentshield_0.2.1105_linux_arm64.tar.gz"
      sha256 "1158d0a461ad59ab317e4b8f27646669b2a9fbf150e6d2ba3668b9275b746ce1"
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
