cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.119"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.119/agentshield_0.2.119_darwin_amd64.tar.gz"
      sha256 "5ec1d8be71a51fc4124d22265549d3d4d0ee6d26936c2eb168ee38de18a697f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.119/agentshield_0.2.119_darwin_arm64.tar.gz"
      sha256 "3d4c6adb1d246fde3563a90f789a449c90c37cab03dd3971e4ae45ae9b71efe7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.119/agentshield_0.2.119_linux_amd64.tar.gz"
      sha256 "c61bdb8ab02a56bf42abf9cf9e8fde4d0d15325d21fea0ff03eb20d6221ea84e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.119/agentshield_0.2.119_linux_arm64.tar.gz"
      sha256 "70f6775cfc2addcb94b7bd692c3c1deff297406f8a50121a1832a56e6f119510"
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
