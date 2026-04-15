cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.594"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.594/agentshield_0.2.594_darwin_amd64.tar.gz"
      sha256 "ad5c07f53cd24379395cdbff1238fb229f93fd419d0670dbc469bff2e8634434"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.594/agentshield_0.2.594_darwin_arm64.tar.gz"
      sha256 "036d933dfd527418740683d06043bb8bc89251fa06adf95e8366cfdeb99729a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.594/agentshield_0.2.594_linux_amd64.tar.gz"
      sha256 "93d3e4d46314eeefdfcfe0d304adbe2b0e3b96dedcaa329fc10abf67df1668f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.594/agentshield_0.2.594_linux_arm64.tar.gz"
      sha256 "1fdaa1a222203311d655a184849c57e964c89da8c0620b84f6b1c045d3825089"
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
