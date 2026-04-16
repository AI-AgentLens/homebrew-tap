cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.610"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.610/agentshield_0.2.610_darwin_amd64.tar.gz"
      sha256 "6117bfe7628170807ede149b51b779113ae9a0ddb01c4134423c8732ae226415"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.610/agentshield_0.2.610_darwin_arm64.tar.gz"
      sha256 "d1fb2b4bff3c40e778d87eff94b804a83946f9259a4736e95d03dc804e5b8d0c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.610/agentshield_0.2.610_linux_amd64.tar.gz"
      sha256 "eb50460fdef9f5f1261fe8227d62e6e3aa6718f0499dd25f6034d8333262aa9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.610/agentshield_0.2.610_linux_arm64.tar.gz"
      sha256 "9b0881c301c2122167dd710647e47f19f5e15ccc4bc41d08643156bbd8018bea"
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
