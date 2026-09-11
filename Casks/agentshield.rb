cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2119"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2119/agentshield_0.2.2119_darwin_amd64.tar.gz"
      sha256 "ad46396ff1ec569e83b490bcf9e2367a5d0870657de80ce2bbe42b221aa0d7b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2119/agentshield_0.2.2119_darwin_arm64.tar.gz"
      sha256 "407df396d8c9aa457616701a5eaacccdba888659b30072e0f6af41f7cca33e7d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2119/agentshield_0.2.2119_linux_amd64.tar.gz"
      sha256 "c93ba61fb17344c456a5daf0af5dd570692c812ba17e7f5b69c1a3792d3b11e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2119/agentshield_0.2.2119_linux_arm64.tar.gz"
      sha256 "0ee3d2ff60b2fa644de20d7de032eaff8bc73782bae48376f82bcd076cf4f4fc"
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
