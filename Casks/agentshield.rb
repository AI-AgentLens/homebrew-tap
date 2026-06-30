cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1504"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1504/agentshield_0.2.1504_darwin_amd64.tar.gz"
      sha256 "dbeda46ea871c7e33441b68e854edcf8f16a333328d611f0d16109397c84fd40"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1504/agentshield_0.2.1504_darwin_arm64.tar.gz"
      sha256 "71d18fe9d597760d0eb8d92d7345972701a51576dd846c5f54df2fe9e546f8c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1504/agentshield_0.2.1504_linux_amd64.tar.gz"
      sha256 "d8cd417e000c33c23caf62629733aa5ee7d2a44b6c08ba8c880125622099c181"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1504/agentshield_0.2.1504_linux_arm64.tar.gz"
      sha256 "dbae6578148ed10db3dbd773fda4eb55a99c082b667d67a7c1b569ea53320c43"
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
