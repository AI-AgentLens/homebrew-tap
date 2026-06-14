cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1312"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1312/agentshield_0.2.1312_darwin_amd64.tar.gz"
      sha256 "f22e35a74ec0fc988be7d9406a996f4318e84dfe387d127e63db5dbf0fb47af8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1312/agentshield_0.2.1312_darwin_arm64.tar.gz"
      sha256 "cf7cf210ee0df70d6ad091811776933df829014d9aec93847173cb23627fb7c6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1312/agentshield_0.2.1312_linux_amd64.tar.gz"
      sha256 "18edbdfbeaf8262a5d6c365b319de5809018938619297e5de84e25cc782d2bd1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1312/agentshield_0.2.1312_linux_arm64.tar.gz"
      sha256 "72fa8abcfdb597f12523357c9d65ea54ff6e78a68ae20a4a5a68b7d58751da54"
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
