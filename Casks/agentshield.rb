cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1179"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1179/agentshield_0.2.1179_darwin_amd64.tar.gz"
      sha256 "7171ee39aea0606e7befca0c30e19044a0c14af10861615bf2edb89ef6d7fbe0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1179/agentshield_0.2.1179_darwin_arm64.tar.gz"
      sha256 "914f292d74fc3869561997d84afadcb7b510527668558b42302a34a863b4ff60"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1179/agentshield_0.2.1179_linux_amd64.tar.gz"
      sha256 "f2b34b46fd7657feed24a0722c500bd82dd66a06baa17425b6f714be01539419"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1179/agentshield_0.2.1179_linux_arm64.tar.gz"
      sha256 "07292e5247d73684601231203d443338aa5bc386130386f78dfdb3aa4d671172"
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
