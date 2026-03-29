cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.205"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.205/agentshield_0.2.205_darwin_amd64.tar.gz"
      sha256 "e2c78a115b1471cabe5d8ad4731ada4df514e8ccdbd143757aad582b814ea091"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.205/agentshield_0.2.205_darwin_arm64.tar.gz"
      sha256 "4e31f2c6ec97f6690fcaa255faea86c41547504d29cabf24656fce77ec3ffe53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.205/agentshield_0.2.205_linux_amd64.tar.gz"
      sha256 "6d85b8be607def5fd07a5f3b25318300b5b412b9348178f866bdea42e6cdb5ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.205/agentshield_0.2.205_linux_arm64.tar.gz"
      sha256 "52a823be031404f6c28684991f3240244d4f54c1e0bf58a6ea558fdcccad9ac7"
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
