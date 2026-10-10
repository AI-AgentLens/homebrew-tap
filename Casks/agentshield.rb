cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2392"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2392/agentshield_0.2.2392_darwin_amd64.tar.gz"
      sha256 "2437601ef2f052981176072a0cae838a9b81e323e0aafcf8873a13b3abfa4d03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2392/agentshield_0.2.2392_darwin_arm64.tar.gz"
      sha256 "e1ba268bdbb2f50f5ba355126d81e2d96675d9fdb686f442f9e289d746272057"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2392/agentshield_0.2.2392_linux_amd64.tar.gz"
      sha256 "f4be59b450fa59217c778931091470a8209c84407b7a564a8f42ff0e8b31a66b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2392/agentshield_0.2.2392_linux_arm64.tar.gz"
      sha256 "5579e922cf42c58404a68be5adb97e9b2861eb9486522456d3e4a4a4adbbf1d9"
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
