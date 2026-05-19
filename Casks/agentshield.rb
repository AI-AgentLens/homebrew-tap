cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1031"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1031/agentshield_0.2.1031_darwin_amd64.tar.gz"
      sha256 "f6392eb58270338b75a013886850f3f98c386cb7943776165b562b54c5613e27"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1031/agentshield_0.2.1031_darwin_arm64.tar.gz"
      sha256 "18728d5b816ddaeeaddf2adee60523e39cbb446df535da54702fc78fdf1cf751"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1031/agentshield_0.2.1031_linux_amd64.tar.gz"
      sha256 "8a80e91a9ee2fd7726302578f4d3be75c4009ff48a8027a1c2d968077104decc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1031/agentshield_0.2.1031_linux_arm64.tar.gz"
      sha256 "b2785aa822481b3a466db25f6f414a25a2a1924420d9648b2306c83975c17e45"
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
