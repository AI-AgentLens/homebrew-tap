cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1797"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1797/agentshield_0.2.1797_darwin_amd64.tar.gz"
      sha256 "135ded5dbea3a4835642d19ede710aed028af59f16fefbfbcebb26fe2b339a75"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1797/agentshield_0.2.1797_darwin_arm64.tar.gz"
      sha256 "735a9abad5c26dd6fd0035b9feb9929e872d348358ff44f817cd01d2e79785c7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1797/agentshield_0.2.1797_linux_amd64.tar.gz"
      sha256 "afe1da110de8bb822967914d829626bf87f14a2302b7cb321bc61f1741cb27b5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1797/agentshield_0.2.1797_linux_arm64.tar.gz"
      sha256 "ae2200c92943797218e510c0c4f6de1ec03025dd0c5f5c9abe4585923ddedbfb"
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
