cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1557"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1557/agentshield_0.2.1557_darwin_amd64.tar.gz"
      sha256 "a17cabedb70f2220b7c80966f8daac89dc1a009db19e67756000895b2ab27178"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1557/agentshield_0.2.1557_darwin_arm64.tar.gz"
      sha256 "7e7045be6bde10b40892697a6480e254f6af8e7b5d4f42ba6219b2e86e79acf1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1557/agentshield_0.2.1557_linux_amd64.tar.gz"
      sha256 "728931b3a3644c5a2658dcbb2a43b789a5228e4a99eacbe7c2bba42230a047bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1557/agentshield_0.2.1557_linux_arm64.tar.gz"
      sha256 "4dd57bcb054645daa02a839b6a22ec790ba02d85fbc21fa9037651268a496936"
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
