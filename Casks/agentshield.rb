cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2399"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2399/agentshield_0.2.2399_darwin_amd64.tar.gz"
      sha256 "20fbe98a71faac70ac18f64f649ac76a28ef2ddca5f6ef963271f9f898cfb887"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2399/agentshield_0.2.2399_darwin_arm64.tar.gz"
      sha256 "fc95a80af5c8def9a67ffc202ee20d8ea0da9dbe9093903304bb174623eea6a6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2399/agentshield_0.2.2399_linux_amd64.tar.gz"
      sha256 "8f23a426d490275ef65627fa462bcddc46f5032b87cb2c4140b7a1cdb54a901e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2399/agentshield_0.2.2399_linux_arm64.tar.gz"
      sha256 "3d494f765b7fab1f0db26bfa1d7ed6255b08ef9c38ad30efc7cf09a92ded634b"
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
