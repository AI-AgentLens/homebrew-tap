cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1657"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1657/agentshield_0.2.1657_darwin_amd64.tar.gz"
      sha256 "2d48d49fe2f7db0b5d1ab259072b53f4955898b92e339ab6104c955c5fc7c94e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1657/agentshield_0.2.1657_darwin_arm64.tar.gz"
      sha256 "2cf4f3041e310207c008dbc399dc0a94c6216245d03a5be116e832bef0db5ba1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1657/agentshield_0.2.1657_linux_amd64.tar.gz"
      sha256 "5eb49af78f74b662ef76e28f1a6f8721dcae08610136521f3908be3682ddf294"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1657/agentshield_0.2.1657_linux_arm64.tar.gz"
      sha256 "6cb7199bbb7d37372ded367a17c8deaba1ba150ac9917c96b5654c92312b96d6"
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
