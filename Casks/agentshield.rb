cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.159"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.159/agentshield_0.2.159_darwin_amd64.tar.gz"
      sha256 "e246bb65e7e197ed3b26e6802254e857a71c2126975d18b72f66e4de2d0dab5e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.159/agentshield_0.2.159_darwin_arm64.tar.gz"
      sha256 "6933a4bfec2f331f04a7cd9472ead107bf66eb02b82a379ae9c87593fdaccf55"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.159/agentshield_0.2.159_linux_amd64.tar.gz"
      sha256 "d521a2f145ce313b70fd76a5b43c6949c659e17f73939ce55ef89f87f51a6d19"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.159/agentshield_0.2.159_linux_arm64.tar.gz"
      sha256 "f1e54261a7666e1bcfe88ccaf248377e7136efcc30eda8a1cfa25b7772a3203f"
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
