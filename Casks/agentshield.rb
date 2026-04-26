cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.755"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.755/agentshield_0.2.755_darwin_amd64.tar.gz"
      sha256 "e70e7a8fa6e8d95bfc864adc7f3a748c863cfac3e78cfe0fe74905be6b810827"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.755/agentshield_0.2.755_darwin_arm64.tar.gz"
      sha256 "205f7921e28e7c93e5b3be42dc661cbaff214712ee4fd6b3b2744e2e73e448a0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.755/agentshield_0.2.755_linux_amd64.tar.gz"
      sha256 "2f217f449fe7e1e318159066d0d6387be7aa6f9c796da42f2ffb78b5697c5aaf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.755/agentshield_0.2.755_linux_arm64.tar.gz"
      sha256 "92c08c3121d44b47c9cfc17d7fa483d562016716f226622ec106c1b7aba8c90e"
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
