cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2288"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2288/agentshield_0.2.2288_darwin_amd64.tar.gz"
      sha256 "ff2b6993699b41dac4e13c65967d702790db5e9c7086d9823ce234aab16caa37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2288/agentshield_0.2.2288_darwin_arm64.tar.gz"
      sha256 "4e27cd7d899ca08d2847b88bd37ced4e37b7a142d377de8785624881f8e616f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2288/agentshield_0.2.2288_linux_amd64.tar.gz"
      sha256 "b3a3f3b4bb878a8d003c111277ee6fd6c50b5ef16d2f8bb879c5c18d7a36b31f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2288/agentshield_0.2.2288_linux_arm64.tar.gz"
      sha256 "116f67eac6ec2c7cc52dfa1220fb7d6da0deda4de890c03ffe3f4b1f529497c9"
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
