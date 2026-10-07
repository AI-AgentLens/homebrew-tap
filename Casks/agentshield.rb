cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2365"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2365/agentshield_0.2.2365_darwin_amd64.tar.gz"
      sha256 "514943189b79adb8e51d93436cc3bc1fc83140eb4d9e96b3dc19180b0d03c5e0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2365/agentshield_0.2.2365_darwin_arm64.tar.gz"
      sha256 "12dae97d7cc19251e5c68760f9efdbf64c21a216afdf86b98bcfc2157b8237eb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2365/agentshield_0.2.2365_linux_amd64.tar.gz"
      sha256 "468b343d390cdbe7d63be02c9b340efa85bd193102655b6e5018d4ff16ae82ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2365/agentshield_0.2.2365_linux_arm64.tar.gz"
      sha256 "d3834c7d3fc31bb056fc0cf4f724e935b59fea3e6a85a52481925c5f1ee9c491"
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
