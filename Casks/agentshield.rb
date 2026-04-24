cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.712"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.712/agentshield_0.2.712_darwin_amd64.tar.gz"
      sha256 "aef0cad200e0c91f3715c432297bf11d574e324c0cb61047c76ff1786122b52f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.712/agentshield_0.2.712_darwin_arm64.tar.gz"
      sha256 "cd9e7adba719b8155a7b61839ab4f00c87a5c153d5139d45904da645804bba5d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.712/agentshield_0.2.712_linux_amd64.tar.gz"
      sha256 "7f10c4883ce442509356dfbf59ffb35c50eabb5f771fcddc6ea925db5318385d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.712/agentshield_0.2.712_linux_arm64.tar.gz"
      sha256 "452dad2a87b8cbd86d8ab14496dec2b31ba38e52ddbdc39524e765bccb060696"
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
