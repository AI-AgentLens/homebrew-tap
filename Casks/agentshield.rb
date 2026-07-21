cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1699"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1699/agentshield_0.2.1699_darwin_amd64.tar.gz"
      sha256 "9426ca0a82b3f937e986d168fea31278c809f2838921fe335eedc2b692baba2c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1699/agentshield_0.2.1699_darwin_arm64.tar.gz"
      sha256 "3ae4a39f13f9a5810cdc663183be698e61123674f095df46731db96b4cf18f56"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1699/agentshield_0.2.1699_linux_amd64.tar.gz"
      sha256 "3cd72eebe00e2efc5cd70abecf92d09b3fd4bebc0f6e594d34a531e896bba066"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1699/agentshield_0.2.1699_linux_arm64.tar.gz"
      sha256 "2ed11599d7c32597b5a8d2617055e81f2eb1c66ee7157d64ffedf26f40d53ea0"
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
