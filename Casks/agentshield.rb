cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1686"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1686/agentshield_0.2.1686_darwin_amd64.tar.gz"
      sha256 "eecd1af09cd9e6cefaaf2e9cc434287984720d9a2620f4bc09f09350c783d4b0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1686/agentshield_0.2.1686_darwin_arm64.tar.gz"
      sha256 "756ac6d7c46032955267422e77880e923bae4c917f718f2bffd7bcdc9b3aee79"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1686/agentshield_0.2.1686_linux_amd64.tar.gz"
      sha256 "927088756969a58d0d4064dd3f2a64aec906dd46989f19a670a4aeadf782da7e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1686/agentshield_0.2.1686_linux_arm64.tar.gz"
      sha256 "ce84d003e7989b37f9feccfae5f61da6e9dd0362c472e834189124d5d5784154"
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
