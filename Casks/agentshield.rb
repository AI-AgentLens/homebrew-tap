cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1350"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1350/agentshield_0.2.1350_darwin_amd64.tar.gz"
      sha256 "680f43baa42eb67f3a5db8b863ff387c0c7d7cf1d112f78929269dde8124dea2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1350/agentshield_0.2.1350_darwin_arm64.tar.gz"
      sha256 "4f2146448516d3816dcbf3175c9d122295b42e870138d14315a9d695baff9b98"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1350/agentshield_0.2.1350_linux_amd64.tar.gz"
      sha256 "6b473913a80b2964755b4767a0a5a3b6d1085634c44dbd60c5f3e424d04a5c64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1350/agentshield_0.2.1350_linux_arm64.tar.gz"
      sha256 "da750bece7b135a1c0d2504f2f14ab5e48f8b669034ce8ccf8b2a333317893f5"
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
