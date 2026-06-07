cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1240"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1240/agentshield_0.2.1240_darwin_amd64.tar.gz"
      sha256 "e7063437047d1b9b455eb32d2e241b0fec9aeb4a64de9c1d5791073ae980ae56"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1240/agentshield_0.2.1240_darwin_arm64.tar.gz"
      sha256 "74c781b8bb1f4e72a848938ee8caf9933e78ae41045bafcf45a73183e8f47881"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1240/agentshield_0.2.1240_linux_amd64.tar.gz"
      sha256 "bc295d136cf1a2fdd50ff2472a573236e835954e1c8db31b7a20713700bfe49b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1240/agentshield_0.2.1240_linux_arm64.tar.gz"
      sha256 "7c3540239140c2f420be0e54680e65f101d6b70187b1c8559f4d3527e30e28bb"
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
