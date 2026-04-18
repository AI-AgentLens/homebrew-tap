cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.635"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.635/agentshield_0.2.635_darwin_amd64.tar.gz"
      sha256 "1dd2e4a592358bfd3ce6f27b945cdec204f0ec3c15c53c79be7e17f35baffd87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.635/agentshield_0.2.635_darwin_arm64.tar.gz"
      sha256 "5e9384e35699043fe4e92f4a51cbf292f58384891ea3b8e686bcc89ab901033a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.635/agentshield_0.2.635_linux_amd64.tar.gz"
      sha256 "775ca6c55a9169676f8206ba2a754026c33b39b4649720d800a343a6dca72a87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.635/agentshield_0.2.635_linux_arm64.tar.gz"
      sha256 "87b7c5809a37c961d556b56735e6c7f375fa5e62085c1a3a24e60154d2554fea"
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
