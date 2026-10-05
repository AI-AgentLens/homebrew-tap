cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2343"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2343/agentshield_0.2.2343_darwin_amd64.tar.gz"
      sha256 "59ce8209515843d5f13567f1555272240780f58e523edbdc0261c37ed0ad5a37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2343/agentshield_0.2.2343_darwin_arm64.tar.gz"
      sha256 "e3104d571163686c6479a95abfd6fbfb161e7bd75bdc03c66862a8eb89cebe9d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2343/agentshield_0.2.2343_linux_amd64.tar.gz"
      sha256 "eb59cc4157df9237a70d1c646745dffd9f76de3046fec53778eb3baef28563dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2343/agentshield_0.2.2343_linux_arm64.tar.gz"
      sha256 "ff7f04e68555b636a8523c87e8c4d5b4938afe4a360f2208de1fbcd8bca3bf5b"
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
