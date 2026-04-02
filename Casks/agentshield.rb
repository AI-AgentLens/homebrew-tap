cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.296"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.296/agentshield_0.2.296_darwin_amd64.tar.gz"
      sha256 "3a1fed5e0514102f4b9977fa6584081a4647da93df39378f7464c092976122fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.296/agentshield_0.2.296_darwin_arm64.tar.gz"
      sha256 "ce25570876aefc88e6bcab4b34072225ccd5f51b0cfb3772ca586d37c5ee5ada"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.296/agentshield_0.2.296_linux_amd64.tar.gz"
      sha256 "be2b08c5d3440a56a97b3416e09c4f6f5d83ea3cc8f8ba29ccbc7037032d6081"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.296/agentshield_0.2.296_linux_arm64.tar.gz"
      sha256 "a613b2c8177aacc9b1128c05954210a9af06d2c4c4cd91ea56d60dc32c58c355"
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
