cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2488"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2488/agentshield_0.2.2488_darwin_amd64.tar.gz"
      sha256 "31e7748dc1673b70e61df111180309ab522d9b57bf522637c884da7912953c3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2488/agentshield_0.2.2488_darwin_arm64.tar.gz"
      sha256 "fc8d7c17c107f2d294029db4b221123698f31b529c2f86c7c383baa13a61fb68"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2488/agentshield_0.2.2488_linux_amd64.tar.gz"
      sha256 "61c43af098ab36f3ee4311fdbb1bd8e7616187a8afd92a22d400e7ec624ebd48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2488/agentshield_0.2.2488_linux_arm64.tar.gz"
      sha256 "f5d05fb31c006f155b58512688ce39145a4800f756b2d1f44ba999e3ffc2b2d1"
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
