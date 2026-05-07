cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.900"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.900/agentshield_0.2.900_darwin_amd64.tar.gz"
      sha256 "ce3a8056282c3c6701f837ff20a45ffa815ca69ddb2a8908468b2073713ed556"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.900/agentshield_0.2.900_darwin_arm64.tar.gz"
      sha256 "27a260a1a9d191a6999036be3bd6ad7131965fc0285e3f43b62ba7f835463332"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.900/agentshield_0.2.900_linux_amd64.tar.gz"
      sha256 "bca3a29670dfd2be8af6e3b1b9c930723704ec7cf668cc1b0ca4f8cc93b1ffcf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.900/agentshield_0.2.900_linux_arm64.tar.gz"
      sha256 "fa53cc9343dbc6cc9bc88254d871c269600890a0ee9cd584e93143dabd39880f"
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
