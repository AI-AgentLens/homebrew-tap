cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.604"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_darwin_amd64.tar.gz"
      sha256 "a26951980227de2e97c396da4e9f388f3592f961e2a3428a06c83ec35985fcca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_darwin_arm64.tar.gz"
      sha256 "bc9fc72bc76ea5937102cc0b80b4250224c6a58f64af5880c31396c4fb6f6acc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_linux_amd64.tar.gz"
      sha256 "e70cfddc3e3135c3037d29243963d3cfb31e13bf1f566dbcfb1bd52dfebd3405"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.604/agentshield_0.2.604_linux_arm64.tar.gz"
      sha256 "7bf57360ae0b4954aa855f07d4d086cf953c1cb257231efe536e24c0796c7eb4"
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
