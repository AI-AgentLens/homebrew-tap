cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.240"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.240/agentshield_0.2.240_darwin_amd64.tar.gz"
      sha256 "29542daadadc62f43b1358540386cbf6dae3d211e3b22992c0db81ec3740861e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.240/agentshield_0.2.240_darwin_arm64.tar.gz"
      sha256 "42914964cbf47ef33859762454447cb10de2c6a690f8f8f05b87a1cc57e83df9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.240/agentshield_0.2.240_linux_amd64.tar.gz"
      sha256 "86440ed9074fcccd7f081c43cd73c7a990e1cd2fde6b94075b00894583b79051"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.240/agentshield_0.2.240_linux_arm64.tar.gz"
      sha256 "5bc849858f7ec882fb97b2c7603356c6d74048263fedee782b0aec1921ecf497"
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
