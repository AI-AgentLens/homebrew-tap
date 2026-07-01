cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1513"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1513/agentshield_0.2.1513_darwin_amd64.tar.gz"
      sha256 "813234f207845322912e5097294573af5b10ff145a64b6288546c99df4bfaf86"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1513/agentshield_0.2.1513_darwin_arm64.tar.gz"
      sha256 "6079fc09252740146ea9e3e90dc0348fe52c377807173ce82cdd04004f40a427"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1513/agentshield_0.2.1513_linux_amd64.tar.gz"
      sha256 "62577fb4eac9f744cd9084ba86b1338e77ad6e8ebf5a8a1fb85261f84e2e9733"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1513/agentshield_0.2.1513_linux_arm64.tar.gz"
      sha256 "0bc4157509aa2fe62781e4fe3814df2aafe55a2f5675355992874260587bcdc6"
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
