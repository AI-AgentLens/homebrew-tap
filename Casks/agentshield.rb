cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1585"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1585/agentshield_0.2.1585_darwin_amd64.tar.gz"
      sha256 "420654d0cf128dcc34bb1fbe08482b9f196990a3c389635df056337b1a694880"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1585/agentshield_0.2.1585_darwin_arm64.tar.gz"
      sha256 "6b54b2ea04ccc3077b5da6d576b6e3af3c6d6deb6176c303351ae51ea9377d70"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1585/agentshield_0.2.1585_linux_amd64.tar.gz"
      sha256 "dffa7f742d54270b7d079c5d9327a6f9080b95c36af258a1a1ba64b587c1ba63"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1585/agentshield_0.2.1585_linux_arm64.tar.gz"
      sha256 "29a899361cb4ed5ad523ed477f5cc0e3fc8794fa7906b7879bde321be6eaa6c4"
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
