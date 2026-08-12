cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1830"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1830/agentshield_0.2.1830_darwin_amd64.tar.gz"
      sha256 "1b0c3c6d1f868d157c3b9687aca2a6623a7396dba19f5025a94d07914616c89b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1830/agentshield_0.2.1830_darwin_arm64.tar.gz"
      sha256 "7a144cafa9b343243cbf902d7bbad3e229e2a6fbcfe05f14a7c667e69fa84f2d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1830/agentshield_0.2.1830_linux_amd64.tar.gz"
      sha256 "5ab80be3decf6669d6eb0d8b6287d77431237dc898a3a52bbf81106839410f04"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1830/agentshield_0.2.1830_linux_arm64.tar.gz"
      sha256 "4a57748ef052828ccc996a1223d5bf0f9a187afacc46e5e303df572aaf7153f8"
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
