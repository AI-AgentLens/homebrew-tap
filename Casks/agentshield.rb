cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1646"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1646/agentshield_0.2.1646_darwin_amd64.tar.gz"
      sha256 "99288b4c528bee693dd55c68c0412864ed71c7469514e105f0d35704dcc6e381"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1646/agentshield_0.2.1646_darwin_arm64.tar.gz"
      sha256 "5781819a4ad6234ae41eb9c2e3885c2ba4a202f2bd6e027f7ca8b22b88527e1c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1646/agentshield_0.2.1646_linux_amd64.tar.gz"
      sha256 "7302dd686069fbcbd7222032c07701231f6354bc4f312d45a8bed1b33cf6150b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1646/agentshield_0.2.1646_linux_arm64.tar.gz"
      sha256 "f2090d9d46d4dc2b84f33a07066885eb2b80ca1aa7cb74a8e2f8d55a1ab8209d"
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
