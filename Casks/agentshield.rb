cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1406"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1406/agentshield_0.2.1406_darwin_amd64.tar.gz"
      sha256 "e3dc9da9e2b468e9373fb29b86c7429c66b345f2f8f5d9eb2b41cec1c72d76c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1406/agentshield_0.2.1406_darwin_arm64.tar.gz"
      sha256 "ab080a2371154928f6fd83b1489f6ffb79e23397e2cc65494c0c16ce8255b1f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1406/agentshield_0.2.1406_linux_amd64.tar.gz"
      sha256 "ef0f37ae3e562bd1b8eebf0c982a74cda92544454542195a0b650e0bac6492f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1406/agentshield_0.2.1406_linux_arm64.tar.gz"
      sha256 "bbb99050c19bf1380b2d7df799979f96d0665e8194b2a36a5c01626ac5190808"
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
