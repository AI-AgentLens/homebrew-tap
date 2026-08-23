cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1937"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1937/agentshield_0.2.1937_darwin_amd64.tar.gz"
      sha256 "4ff272dcda536be493756e1a9d40a19aec8c310f9db0b7787f9ea83fa8dae0db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1937/agentshield_0.2.1937_darwin_arm64.tar.gz"
      sha256 "2f70aba019fcbfff99dc9af785b26d232df61f85715f8fdeaf91d163f1b4d42a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1937/agentshield_0.2.1937_linux_amd64.tar.gz"
      sha256 "ea70eb3446a6d447946da762f537d16decfadd82878b224e1812d9da8699bbd4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1937/agentshield_0.2.1937_linux_arm64.tar.gz"
      sha256 "c2d7a8df4b05a74aab4e3fa9fd554980f8b61ae87b1700a77b74465c3bcc8639"
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
