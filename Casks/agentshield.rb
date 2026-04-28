cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.786"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.786/agentshield_0.2.786_darwin_amd64.tar.gz"
      sha256 "e47001cd9f39f23146a30c4431a29a66a78bc4988d342670496a244217eebae5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.786/agentshield_0.2.786_darwin_arm64.tar.gz"
      sha256 "30e704cf7255b1e3c6aed25f30ffcb79af62fd00bc7c77ade4b57aa1ebe1234b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.786/agentshield_0.2.786_linux_amd64.tar.gz"
      sha256 "f883be12916b2312532e01e85e15680f41fc45cebb72e126aa737c1e2ecf5079"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.786/agentshield_0.2.786_linux_arm64.tar.gz"
      sha256 "9e4d9596c9ce5aae5e8ef24091a33e6afa2555ec4627e3dcd198c3968316e677"
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
