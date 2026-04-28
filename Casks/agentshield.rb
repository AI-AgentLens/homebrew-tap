cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.799"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.799/agentshield_0.2.799_darwin_amd64.tar.gz"
      sha256 "00dac9fa56aceb2bef5c9972f667b70c16b139b9816d15c8abfb85602b7ccf91"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.799/agentshield_0.2.799_darwin_arm64.tar.gz"
      sha256 "bb14ed83e83976387c35a93bb67e40b2cafffd7eacef7bd5e66e34516b0a55c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.799/agentshield_0.2.799_linux_amd64.tar.gz"
      sha256 "58bca08ca8d7f4fb96d34bc6f056deec387535662d5faffbe6b2eeb800574323"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.799/agentshield_0.2.799_linux_arm64.tar.gz"
      sha256 "64c4993ef22a5cc81648ec2c87c2b3c502524989352a900e6ce30c17d698c14a"
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
