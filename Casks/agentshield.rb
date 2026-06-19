cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1372"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1372/agentshield_0.2.1372_darwin_amd64.tar.gz"
      sha256 "5b1c1586ac0112d5d7135cf1b6f08efc0aab50e61334943390ce56a0553c20af"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1372/agentshield_0.2.1372_darwin_arm64.tar.gz"
      sha256 "86b1d4764eec0f05e1a20540ec59c317922af8d391c5af70aec545d0eb299385"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1372/agentshield_0.2.1372_linux_amd64.tar.gz"
      sha256 "032b099d87a6b548890c5aae7fbdd3fb4c6e542a57f11b566109fe535c7c0c0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1372/agentshield_0.2.1372_linux_arm64.tar.gz"
      sha256 "e97a76cb5d439ab2164d8d7db3a5702833e3a35b61ac7d228dbc2364b8e24882"
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
