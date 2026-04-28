cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.791"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.791/agentshield_0.2.791_darwin_amd64.tar.gz"
      sha256 "b25d9ff470dd8d74bd645ed72e6a6b79b5fd51fa7495d3e95b065cf9cd7d2416"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.791/agentshield_0.2.791_darwin_arm64.tar.gz"
      sha256 "823c617c3fdb169c3e72a1c21650427004fe58407f7d70a4175e4321b7f19f17"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.791/agentshield_0.2.791_linux_amd64.tar.gz"
      sha256 "b19d4cb4641e1b2194d09783ac06436e86d99b4c5cda5ea729fb2c1b76d04612"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.791/agentshield_0.2.791_linux_arm64.tar.gz"
      sha256 "629a795ada4da696af29f21e1cdd65547dca0eb4ad9de6c07ad5a663af8aa31a"
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
