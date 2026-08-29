cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1979"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1979/agentshield_0.2.1979_darwin_amd64.tar.gz"
      sha256 "e4e0ffce88c63b4dc5b1f029307c59c0713d83aebbb2028bcc258bb63c3f3dc0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1979/agentshield_0.2.1979_darwin_arm64.tar.gz"
      sha256 "05e442ae5b83e32ee6ceb858a52d839f11ca927555f4cda52d9fc8fb29de7f1b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1979/agentshield_0.2.1979_linux_amd64.tar.gz"
      sha256 "1b128dfa2dedc27c69d23f35fcf5c10a51de50f634d536741d59b7780ca076a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1979/agentshield_0.2.1979_linux_arm64.tar.gz"
      sha256 "e8eaf20535a4609cd994295cb77c9052ab3fcd2451772ee26a3abecffbf380d6"
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
