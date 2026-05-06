cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.892"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.892/agentshield_0.2.892_darwin_amd64.tar.gz"
      sha256 "3466acb2c2e9287aa5860c7efdd5a063d8c2588fb1054ba22928142cdbcb9c53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.892/agentshield_0.2.892_darwin_arm64.tar.gz"
      sha256 "27af94d6316a092876fdad90141a48e3d1a7c4d9d4e99759e7897574dd222e50"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.892/agentshield_0.2.892_linux_amd64.tar.gz"
      sha256 "5cbba5dea9f1d6b516049efbb0e8094e1b06c736a157ddce479082e6363af9e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.892/agentshield_0.2.892_linux_arm64.tar.gz"
      sha256 "6e436ab7f27c44e5466ad515a95cf8508bb479394f7126f4f12227254e25b67c"
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
