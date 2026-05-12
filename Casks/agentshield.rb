cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.952"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.952/agentshield_0.2.952_darwin_amd64.tar.gz"
      sha256 "806db30786fb6ba77756ac48d8b568847614ae38aa04ce03ea0bd8d3d5cfe41a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.952/agentshield_0.2.952_darwin_arm64.tar.gz"
      sha256 "964634c29bfee4c5342ef17fec73d221910bb2c42230b2726590ef93c55f6a49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.952/agentshield_0.2.952_linux_amd64.tar.gz"
      sha256 "a108a8908c180f08ad02f52c79706a9ee576fd9b2a1ac228fe4c038a06605c04"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.952/agentshield_0.2.952_linux_arm64.tar.gz"
      sha256 "9ec6bc590ae00209d6817bab0d6ebfd3c9195c066173ae5bb2feabe9df0c45f0"
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
