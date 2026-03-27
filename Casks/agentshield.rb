cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.98"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.98/agentshield_0.2.98_darwin_amd64.tar.gz"
      sha256 "782d973901b8c8c8c2ae4ab48a7edec83517d56e6a13aba9859f8d2fe4a0cd09"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.98/agentshield_0.2.98_darwin_arm64.tar.gz"
      sha256 "c6a1b237ff5690c73e73cc8019354b1c11efc0d3028bb4f140ed86f01d9da791"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.98/agentshield_0.2.98_linux_amd64.tar.gz"
      sha256 "2df5746bf77a9509ce34b41670232efcc626354c469300fef0ce481a5a8e3853"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.98/agentshield_0.2.98_linux_arm64.tar.gz"
      sha256 "757f9815dc43b96bd5419806b883dd3f45f5d8917bacd0198cf4a967b90548c9"
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
