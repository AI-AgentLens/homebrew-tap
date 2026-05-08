cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.910"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.910/agentshield_0.2.910_darwin_amd64.tar.gz"
      sha256 "08f1f0ea07d83fdcd6383f71047e15459239dabd5a178dbb0e4b37a5edfd0a18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.910/agentshield_0.2.910_darwin_arm64.tar.gz"
      sha256 "2b6199a3f93f10632b39b148cd362ca32f79742529012d7b714eeda4f6d83f33"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.910/agentshield_0.2.910_linux_amd64.tar.gz"
      sha256 "9136ce9c61b61fd10f2f9818a09f7f95bbb683110217a089aaac41313c5c14f6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.910/agentshield_0.2.910_linux_arm64.tar.gz"
      sha256 "deb4171763b97e7596a5b216fc34b98e10af1294d851eb0ddb3abec56f464164"
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
