cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.987"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.987/agentshield_0.2.987_darwin_amd64.tar.gz"
      sha256 "ceeed3c5d3dc6d8ecf6a84500e592e0f269343f34028ec535466514b680d470d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.987/agentshield_0.2.987_darwin_arm64.tar.gz"
      sha256 "baedd8d191da8874d9b1268c4c87f3187e8e6560fca59dd78b044d5a601c8211"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.987/agentshield_0.2.987_linux_amd64.tar.gz"
      sha256 "a6f09e148abe2d1a6b47de9d68ca6366b7fb0d9ab56f96186769162da3298205"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.987/agentshield_0.2.987_linux_arm64.tar.gz"
      sha256 "2cc302717332bbfc5b15815617d8c96bcd1a1eed034727c5feef8795111ab300"
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
