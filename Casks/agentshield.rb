cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.772"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.772/agentshield_0.2.772_darwin_amd64.tar.gz"
      sha256 "3463a0b1ab859b725faf7b59fa7c2369b5a0f97c5dcbaac150ec171ba429049c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.772/agentshield_0.2.772_darwin_arm64.tar.gz"
      sha256 "e0ea14d5676cc3d320af9331c8cec823c975536b0d7207462f08478c310c0ec4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.772/agentshield_0.2.772_linux_amd64.tar.gz"
      sha256 "8c75be3508429a58fcd271f3939f474b946a6941fea26d7af2d81c3a858c4a10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.772/agentshield_0.2.772_linux_arm64.tar.gz"
      sha256 "869cb0828c36344bb3a1b74ccfcd5130bde80d0354378554028e9a201b9a735b"
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
