cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.556"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.556/agentshield_0.2.556_darwin_amd64.tar.gz"
      sha256 "03e20c685df11c7a68b53609fcbe37a0a20a32f8d8a823cfbcf488630564a5ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.556/agentshield_0.2.556_darwin_arm64.tar.gz"
      sha256 "3c33ce7a674c26da7f9ce2befea98d2f399bab9e01145d1a3f8f73ff1e2150fb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.556/agentshield_0.2.556_linux_amd64.tar.gz"
      sha256 "af1d4ab7772f280d3dc9e77fbac4842b71499552ef89f906798c3e4ebaf7e498"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.556/agentshield_0.2.556_linux_arm64.tar.gz"
      sha256 "3be6ef05932d41fcccb6239f0950ae1ed9ae83227709dd534f7682e9839eda65"
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
