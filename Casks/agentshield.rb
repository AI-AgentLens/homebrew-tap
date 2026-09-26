cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2266"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2266/agentshield_0.2.2266_darwin_amd64.tar.gz"
      sha256 "ab3a51c5c0842d8f248904d20d0503f09e77d7ba90517b2c0ad3f44c37c9fabf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2266/agentshield_0.2.2266_darwin_arm64.tar.gz"
      sha256 "4c4f35b8640ae4f19211eed86cc6c9c68470aeb8c5afa4b566ea7a9c30f6f709"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2266/agentshield_0.2.2266_linux_amd64.tar.gz"
      sha256 "b43674550deda7a65349bbc3c87054ccf0573a7fcc6aa2d383fe4b279c4dd7f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2266/agentshield_0.2.2266_linux_arm64.tar.gz"
      sha256 "2b49e948a3db9df2db420df68b2f673c17d941ed5bfbe5cdacec5886ab602385"
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
