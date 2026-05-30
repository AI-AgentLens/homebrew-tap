cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1154"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1154/agentshield_0.2.1154_darwin_amd64.tar.gz"
      sha256 "083633d21c73f611655fe7e61def189677787e28d34ce5ae0278176f4523d742"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1154/agentshield_0.2.1154_darwin_arm64.tar.gz"
      sha256 "b92fb97c62590f66fa6283c5548bfcf5ce8c05ecbe11a267606478c957026fb1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1154/agentshield_0.2.1154_linux_amd64.tar.gz"
      sha256 "b89f9999bc48dff449bc3428b7d26de744f7f6bb7562d759a2c5b4f1e16ba251"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1154/agentshield_0.2.1154_linux_arm64.tar.gz"
      sha256 "cf045159b839371e3b51307b3b85c65dacfbb7f78590fd7b87f60bf918d413c8"
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
