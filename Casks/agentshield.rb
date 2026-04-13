cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.567"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.567/agentshield_0.2.567_darwin_amd64.tar.gz"
      sha256 "2b902215a953e42a8b8f9f11b1220adaf688defaa640c5b993abd5a257ce7226"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.567/agentshield_0.2.567_darwin_arm64.tar.gz"
      sha256 "3404e3a75642efe5b5a50fbebaf496551895f4903a9423059e8e91158912fd71"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.567/agentshield_0.2.567_linux_amd64.tar.gz"
      sha256 "fd257dec890d7d4f2f1279bc8d904c9b68d921796068a61f5d08d0c114a4c4d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.567/agentshield_0.2.567_linux_arm64.tar.gz"
      sha256 "e775c6413e1ebc65f38802655689cdd4688cd74b417cee4351d7904aca7e4800"
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
