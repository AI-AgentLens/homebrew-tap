cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.882"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.882/agentshield_0.2.882_darwin_amd64.tar.gz"
      sha256 "dd7bbd5000d0651c6f8924036927229f0ae8684d724ee3836f31180b41d414a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.882/agentshield_0.2.882_darwin_arm64.tar.gz"
      sha256 "e603d6966b22cce42926d417415e24ed14e114dac3201af02fe28095ad05413a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.882/agentshield_0.2.882_linux_amd64.tar.gz"
      sha256 "c7c8518b789c71382d2cc83c6eff097244cf2b4c5603c2f57cbdf4ac1ec3c763"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.882/agentshield_0.2.882_linux_arm64.tar.gz"
      sha256 "664b9be77d0ee0d0e501e5a420d674905713569cb47b655e18f33413113f9481"
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
