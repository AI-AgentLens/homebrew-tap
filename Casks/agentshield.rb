cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1305"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1305/agentshield_0.2.1305_darwin_amd64.tar.gz"
      sha256 "7fd65039be3ce5b835730567e91121964cdafdc48df9165a7634473c9f94dca8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1305/agentshield_0.2.1305_darwin_arm64.tar.gz"
      sha256 "75e1166368f65f60e37f5999dbf65412a3a485ef81b549963dba5d187ac9eb18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1305/agentshield_0.2.1305_linux_amd64.tar.gz"
      sha256 "8ba9ec6e9ce747f6e25df83e16dbf726b30431e8c2dd3a420c56e0d1785045a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1305/agentshield_0.2.1305_linux_arm64.tar.gz"
      sha256 "b73a71d56cd03bc6b29e706d7318b15e3e078afd61c36f615eaf2089444e3635"
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
