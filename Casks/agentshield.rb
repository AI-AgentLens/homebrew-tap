cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1203"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1203/agentshield_0.2.1203_darwin_amd64.tar.gz"
      sha256 "57b43e6bbca0ebe6c69210ba183b5c3f4b0c721a7b54fe5f728f3c75f994edfa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1203/agentshield_0.2.1203_darwin_arm64.tar.gz"
      sha256 "f92f20d1147e2f2d1a1c4804830d54d3b7e18ed059548fc5eab60cd8ac6e4e17"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1203/agentshield_0.2.1203_linux_amd64.tar.gz"
      sha256 "10e24955258cbc5f1c912ec97e222c6bf763c5ae3e96658b3659d145b161c0c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1203/agentshield_0.2.1203_linux_arm64.tar.gz"
      sha256 "a73f4d7b2fd82350c7318a002f9ea9f79fcbe0712a5c1e0198197bad05a373bc"
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
