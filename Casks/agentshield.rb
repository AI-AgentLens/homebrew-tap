cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1828"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1828/agentshield_0.2.1828_darwin_amd64.tar.gz"
      sha256 "b55e087836122287034605b050098b7432264bdc970ce1e131f3c49a2d08e223"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1828/agentshield_0.2.1828_darwin_arm64.tar.gz"
      sha256 "559f59dc0b80b52a09627dbe82c99689a36312ea280351cb8f03dae0b964f3b4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1828/agentshield_0.2.1828_linux_amd64.tar.gz"
      sha256 "b5fd5db4d0b4f71d324dd7bd8d0d7297da64c48cc8449e05fc940097b0f33bd7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1828/agentshield_0.2.1828_linux_arm64.tar.gz"
      sha256 "aa04e5769d0cbf8eb436875f0171b5113f021705cc1efd0ca7259c835fc56caf"
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
