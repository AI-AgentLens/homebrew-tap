cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.749"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.749/agentshield_0.2.749_darwin_amd64.tar.gz"
      sha256 "f0a566ef0e8944ba50480eee4186aa603311c8f9bebd925da97a781105f5fa2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.749/agentshield_0.2.749_darwin_arm64.tar.gz"
      sha256 "d182e6675119b5622116c0fe42c23b10ebf777713c3363fce49a9644eb17f349"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.749/agentshield_0.2.749_linux_amd64.tar.gz"
      sha256 "6039dca0c6045ad3fe407cfe6af6f66afd8e0ed581a75cb2daabe92532695faa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.749/agentshield_0.2.749_linux_arm64.tar.gz"
      sha256 "fdc2d7aab76ca3ce0102d804f3e3de54e724e594e26405a20ddfdf0f11632019"
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
