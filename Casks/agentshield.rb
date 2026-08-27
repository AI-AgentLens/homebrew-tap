cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1967"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1967/agentshield_0.2.1967_darwin_amd64.tar.gz"
      sha256 "b4b9a9ff4dd924988dc8a8e16cc90db46abbfc31d80aecb5df055baf1704166a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1967/agentshield_0.2.1967_darwin_arm64.tar.gz"
      sha256 "c414e741448f63291a661c2c3b439597a846a154cf8342db75f32d20a2cf234c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1967/agentshield_0.2.1967_linux_amd64.tar.gz"
      sha256 "0b1a8e61f4b2b506c79e257e71d195fe834e1be0e490940cf9714df6f98c2604"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1967/agentshield_0.2.1967_linux_arm64.tar.gz"
      sha256 "0e7c744c28078ad97af026caf45a583418ab774e9d22b1529fa8785de90aaa1a"
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
