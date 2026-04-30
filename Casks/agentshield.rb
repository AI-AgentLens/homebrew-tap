cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.830"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.830/agentshield_0.2.830_darwin_amd64.tar.gz"
      sha256 "4718481ee81ed53b6aed6bb35482d23cba4dfac67077b99bb5d785954c51e407"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.830/agentshield_0.2.830_darwin_arm64.tar.gz"
      sha256 "823fadda0c05ace4302dd4783bcc31920224847a42f8a32ffa253c851203f155"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.830/agentshield_0.2.830_linux_amd64.tar.gz"
      sha256 "c177629925a97dcc92b56c3f06a4ada77a639ed0d29318dc1ce32ff8a88f62ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.830/agentshield_0.2.830_linux_arm64.tar.gz"
      sha256 "2f0f1795fa1f5128e58dd3d689e178b7d553b998e15a5434b8bd686215d2b10e"
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
