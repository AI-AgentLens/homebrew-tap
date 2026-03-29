cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.179"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.179/agentshield_0.2.179_darwin_amd64.tar.gz"
      sha256 "af8c2be68b312aaf1ddc8060f053de35ab7f56791843ea83ac0228a0365080c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.179/agentshield_0.2.179_darwin_arm64.tar.gz"
      sha256 "5f37a369059cae370b71fa89bd7f9c37083a8358efeaa850dfbacdcd77f901ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.179/agentshield_0.2.179_linux_amd64.tar.gz"
      sha256 "f65d10e03558763d586b40377d0719bea5b12d3be0d31a85fd9939a17f156285"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.179/agentshield_0.2.179_linux_arm64.tar.gz"
      sha256 "fb074f6c8cd8bd0887598d55f1262469508fe4c08b9890acda8e11675cae88b3"
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
