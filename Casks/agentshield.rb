cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1070"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1070/agentshield_0.2.1070_darwin_amd64.tar.gz"
      sha256 "6acd66c8efa144e1616dabb317070b53a6e1ddfc1465b90da0b726833c26ea35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1070/agentshield_0.2.1070_darwin_arm64.tar.gz"
      sha256 "1a95e0d98e6eaeba05396802c8121a38d0ab590605798e17f1ee8f130a7c49e2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1070/agentshield_0.2.1070_linux_amd64.tar.gz"
      sha256 "7b44a1e061cf06dd9d3552ddde9a8ae0f7be1ef2bed950f7dfce01731e6b56ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1070/agentshield_0.2.1070_linux_arm64.tar.gz"
      sha256 "78b23bedf0de8367e72fb91da5c164114c8eb7d5e60810bc45c3fa07d326668a"
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
