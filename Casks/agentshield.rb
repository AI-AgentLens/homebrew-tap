cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.101"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.101/agentshield_0.2.101_darwin_amd64.tar.gz"
      sha256 "807086e371db67c3e17978a4312fd19ec4c1697d82ed2811255352a3ca6b78d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.101/agentshield_0.2.101_darwin_arm64.tar.gz"
      sha256 "b18336557eb87e89bf49dc643fa3cefbbe8d4d6d5a245c2f3e5a725c4a8f9370"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.101/agentshield_0.2.101_linux_amd64.tar.gz"
      sha256 "d5a41b48447c8f8d6c20a96ae681b61a90208dd09657a36fd16e4854019f7ac6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.101/agentshield_0.2.101_linux_arm64.tar.gz"
      sha256 "e9442d97c80199351968ad2bce4fc0cb2d4e5b85e5431b38139ebeb024a4e74d"
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
