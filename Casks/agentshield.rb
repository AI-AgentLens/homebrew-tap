cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1859"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1859/agentshield_0.2.1859_darwin_amd64.tar.gz"
      sha256 "db23cddcf7c5562cd790bb541c0854f65276e6a523653fdbb4568e6991d660b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1859/agentshield_0.2.1859_darwin_arm64.tar.gz"
      sha256 "2054bb63711414889a2c8fd70ade7540d992b685059e24d4df62d285280a866e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1859/agentshield_0.2.1859_linux_amd64.tar.gz"
      sha256 "999155a2933c551c91d66ddafbee8739117cc3213eb1d5f9f82ba93553a875da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1859/agentshield_0.2.1859_linux_arm64.tar.gz"
      sha256 "769dc78271ab60888b9d7b6d7eed79939fb6373bf3dcca2b5e6ea8b3d0011af7"
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
