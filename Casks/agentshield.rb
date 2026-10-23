cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2509"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2509/agentshield_0.2.2509_darwin_amd64.tar.gz"
      sha256 "7ecc3bc82ac62130af98d1fd67988eb88fee70a2a95dc21e9249204d34d69f18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2509/agentshield_0.2.2509_darwin_arm64.tar.gz"
      sha256 "eeef81569ef998738e376171df86538e32b426f9e165349f61744f81c524470f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2509/agentshield_0.2.2509_linux_amd64.tar.gz"
      sha256 "a4617601433b8f774d1a47321fb5654797349184e9323349005929c82b95a726"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2509/agentshield_0.2.2509_linux_arm64.tar.gz"
      sha256 "5ebb84e60a32a75cb9787fec903b261559bb13d8ea81ac0aac5a215fd0d7a0d1"
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
