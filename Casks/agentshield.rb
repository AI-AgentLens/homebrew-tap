cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2355"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2355/agentshield_0.2.2355_darwin_amd64.tar.gz"
      sha256 "aef6a39a88be239b026df42ec5b69f10067b7da2b479979d72fb2417af4fac11"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2355/agentshield_0.2.2355_darwin_arm64.tar.gz"
      sha256 "ba53fdeb4bcf3fe61b341cee0482c4ebe234f3759802caf96bb994675e21e942"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2355/agentshield_0.2.2355_linux_amd64.tar.gz"
      sha256 "f592ea5bf17e4c5e96ddca980a7cc4e7d8d8908ea2a7c0025317337d4b5093dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2355/agentshield_0.2.2355_linux_arm64.tar.gz"
      sha256 "1612bec6010cc1e5299ec1f797ffa1e32ff31c43707a6a8f2ef85defa23435b1"
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
