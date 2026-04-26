cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.740"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.740/agentshield_0.2.740_darwin_amd64.tar.gz"
      sha256 "607bd234ec1e08bbfd17536d43c8f3e06647572f4c277d18ccaa4a289468b48e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.740/agentshield_0.2.740_darwin_arm64.tar.gz"
      sha256 "9a8bd32260fe1518faa20c89093d876b70d0f0235e5f1978f41955448c2ac22a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.740/agentshield_0.2.740_linux_amd64.tar.gz"
      sha256 "2fdfcfed96179982ff1e121d00fef2c69709cfc3a6fed98f0342a37ee590033a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.740/agentshield_0.2.740_linux_arm64.tar.gz"
      sha256 "4d07b2895167865f61caf240f7b5bce9473aa79b471f66cf79d715df014142f8"
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
