cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1184"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1184/agentshield_0.2.1184_darwin_amd64.tar.gz"
      sha256 "8fe0b3ce50bf8dff0361d4075c09954212472bab561d78cab2d798bee060ad7f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1184/agentshield_0.2.1184_darwin_arm64.tar.gz"
      sha256 "96af214e6475049943886aa100e97d9b47dc3a2173d9a9c94e96118e8c464e70"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1184/agentshield_0.2.1184_linux_amd64.tar.gz"
      sha256 "f850df5a362595df64182a1131f7edbf3416cd75805c6bc0df7428038e7649f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1184/agentshield_0.2.1184_linux_arm64.tar.gz"
      sha256 "cb3ba87d248d8e5c6b46434d3a28d9c75dc3829eadc04315f98e57d5fe7048f7"
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
