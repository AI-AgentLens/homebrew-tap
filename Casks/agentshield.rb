cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.659"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.659/agentshield_0.2.659_darwin_amd64.tar.gz"
      sha256 "ec73f745ea58f609d5a9007c51b96f7cba872764c56ec2503882e6310c825448"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.659/agentshield_0.2.659_darwin_arm64.tar.gz"
      sha256 "5fea5602ec1748788e0346040699af220bcf86de1ac6a49be6ee238f7df9f0c1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.659/agentshield_0.2.659_linux_amd64.tar.gz"
      sha256 "f4dd876572e6a23e9b04b4755d128f0e47024a9b60e5dfa81939af7fd5a8891f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.659/agentshield_0.2.659_linux_arm64.tar.gz"
      sha256 "21efac47e8da53f68bc8a625bad47678dad1f9dc80273cdba8e79649c4188a27"
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
