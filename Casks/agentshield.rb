cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1740"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1740/agentshield_0.2.1740_darwin_amd64.tar.gz"
      sha256 "e2eadf4ad74d90d98763abb62f0fc0eab5b149ac040231fdcd1ee510aaaca28e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1740/agentshield_0.2.1740_darwin_arm64.tar.gz"
      sha256 "e4ab11b6d5f2562735221f26d21f99dadb239515857a5c92b59080539c4e973d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1740/agentshield_0.2.1740_linux_amd64.tar.gz"
      sha256 "f977794ec90f3d6b0b0b96cb4ed82eb51aa36fdfade2289f7363e92716c09cea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1740/agentshield_0.2.1740_linux_arm64.tar.gz"
      sha256 "366ab470420ccb3fde0a924052fdb37fb7da155b03683491bdfe8b88112653fa"
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
