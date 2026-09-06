cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2063"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2063/agentshield_0.2.2063_darwin_amd64.tar.gz"
      sha256 "1eea59cf2523efab1b957a85faae23b2d7dcff145376197766f5565cdc89a178"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2063/agentshield_0.2.2063_darwin_arm64.tar.gz"
      sha256 "4c4c50018aa147a92979288ae7c3e8f7c563f515527cd2371e20a20ffd4425f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2063/agentshield_0.2.2063_linux_amd64.tar.gz"
      sha256 "a44ef4bf79986168769746fa5a0187a247a9f88989a5a7053273b1df9505ade5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2063/agentshield_0.2.2063_linux_arm64.tar.gz"
      sha256 "5bc67cb59dc8d27defee1769baba14554e16339ef0b7f47811074e3b6bb5247b"
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
