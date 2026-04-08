cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.494"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.494/agentshield_0.2.494_darwin_amd64.tar.gz"
      sha256 "be3e2fb722062e74b7fd7bc2073836f71850f1832f6b6b1b848eb87124fda7dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.494/agentshield_0.2.494_darwin_arm64.tar.gz"
      sha256 "f251b4ab20216f36524972476c5136d86f173cff9c79effae5f55ce7567bf3c9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.494/agentshield_0.2.494_linux_amd64.tar.gz"
      sha256 "eeddbe7b4c3c5123eb4b77ce7bef9914d96ae1f86d980a5e30291eee1fcf33cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.494/agentshield_0.2.494_linux_arm64.tar.gz"
      sha256 "77de957fcbaca3a85af177e37a035ebf37554c3c18e6cbd879e4145cbff8b74d"
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
