cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1023"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1023/agentshield_0.2.1023_darwin_amd64.tar.gz"
      sha256 "3a160ab1510f9cc17d44c615bd9109fa5e7475e8af3465e7d08cc45ba0e5530a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1023/agentshield_0.2.1023_darwin_arm64.tar.gz"
      sha256 "3f0c5293470ffa27bb27c701ca39a86c2649bca9061839696f78abb9b0dcb879"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1023/agentshield_0.2.1023_linux_amd64.tar.gz"
      sha256 "e3ef46de3889623f38906737a53ff761b82d90e3640e1ca8eea6d121bdeb252f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1023/agentshield_0.2.1023_linux_arm64.tar.gz"
      sha256 "3fc38571ee2cdf60d4463780ae192ef3030b9419463b96a068c7726167a30eee"
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
