cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.337"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.337/agentshield_0.2.337_darwin_amd64.tar.gz"
      sha256 "36a36792911805f805ca9978520ae133e6ab336c9124deb12652346bd2e604f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.337/agentshield_0.2.337_darwin_arm64.tar.gz"
      sha256 "81b2b23414c2c35487ddb50c7945b3ad8bd20e730b81445555fb1bcb9ee2cd5e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.337/agentshield_0.2.337_linux_amd64.tar.gz"
      sha256 "a6bcc733225e2f391fbac07573ce11a8d238b19a09b2569e35880b18e806f7a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.337/agentshield_0.2.337_linux_arm64.tar.gz"
      sha256 "0d09eeb8a7f933b0ab2d28fcf3f9ecdf32854b625121d268c5ee2d49c1d541e3"
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
