cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.172"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.172/agentshield_0.2.172_darwin_amd64.tar.gz"
      sha256 "8543b6272e5ab159f2f4b8045e79ee0577727b45eb54d0c8abc2b87cb5d84e64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.172/agentshield_0.2.172_darwin_arm64.tar.gz"
      sha256 "21e6a8432f521c56afce95d047acd61effb545c972daaf80f5229c6893fe12e8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.172/agentshield_0.2.172_linux_amd64.tar.gz"
      sha256 "52b0eab3bc2bb4c1937a355f7b8fa01ba005d44c1cbdeb2b62c68f829070f5cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.172/agentshield_0.2.172_linux_arm64.tar.gz"
      sha256 "9054a2e8671a08df414cbb8d123784a92750a7925cf88fc836f087fc6f956de3"
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
