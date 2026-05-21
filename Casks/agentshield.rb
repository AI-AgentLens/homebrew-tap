cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1048"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1048/agentshield_0.2.1048_darwin_amd64.tar.gz"
      sha256 "f744e5237bb3746f058908150f6971a99c228fdd68c25437dbe5d85ab5e17c75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1048/agentshield_0.2.1048_darwin_arm64.tar.gz"
      sha256 "cc3129975b3d4366be52985c9706aafe6b5fa5d2225a08e6c609d5db87bc9e0d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1048/agentshield_0.2.1048_linux_amd64.tar.gz"
      sha256 "76f71c3e498d20fef544fdb4eac74c4192d01d090844b0f1ab51bcfadf6a53b9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1048/agentshield_0.2.1048_linux_arm64.tar.gz"
      sha256 "29f2867e508cf3080452aaa0f2aaf76ea3c56d2eaeb2ea22b367a53cb869165d"
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
