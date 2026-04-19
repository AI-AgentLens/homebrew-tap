cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.653"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.653/agentshield_0.2.653_darwin_amd64.tar.gz"
      sha256 "8553a410989cda18d7a81d9a23f6f1a24ed581a21877cedaf8f4135a7e147289"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.653/agentshield_0.2.653_darwin_arm64.tar.gz"
      sha256 "36a3e0382f013aa8cbad5d5094600fece6265286386912c4812961687445d3bc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.653/agentshield_0.2.653_linux_amd64.tar.gz"
      sha256 "5fb2fb3dd96754f01300a5ce54388aa7142fd94b669a1a328702d34cb33ff0cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.653/agentshield_0.2.653_linux_arm64.tar.gz"
      sha256 "1cc3e3a5839252396095df02bad250f709d052263cb77c3393cd73d876e94fdf"
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
