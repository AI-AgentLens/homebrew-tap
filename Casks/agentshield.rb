cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2444"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2444/agentshield_0.2.2444_darwin_amd64.tar.gz"
      sha256 "fa348e4e76b34fd587ea3945effbbe35bd1c7bec1f641bacd059781e3b800e88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2444/agentshield_0.2.2444_darwin_arm64.tar.gz"
      sha256 "87f921e7278ddd5cbebf7a51d1926db3b23ecfefa8e3bb7c3512219d63257b03"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2444/agentshield_0.2.2444_linux_amd64.tar.gz"
      sha256 "03e9dac3ef7aabc1437830030a97240530f56cfebce0b3c999fd53352032fdbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2444/agentshield_0.2.2444_linux_arm64.tar.gz"
      sha256 "ee2c5161e1f7162e828a6236d13270097a073d68505addb0de157392d58a4e77"
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
