cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1800"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1800/agentshield_0.2.1800_darwin_amd64.tar.gz"
      sha256 "860ff0cdaf5fd34d5e260e03c7ba7aa42f5add6f93432d56b476c0522f2cd6d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1800/agentshield_0.2.1800_darwin_arm64.tar.gz"
      sha256 "704174f526a307f35ca39e373e798b15d472424cb1e35160b931b0f5fdd7dca0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1800/agentshield_0.2.1800_linux_amd64.tar.gz"
      sha256 "a98db4dc639b19f9a2f5903d1b3bd8c06133a497378b446a0cf9247fcbb20172"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1800/agentshield_0.2.1800_linux_arm64.tar.gz"
      sha256 "eb674a74db0fc116119e0c55aef3911f80a794f886cdadb945b9205461b237dc"
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
