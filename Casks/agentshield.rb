cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.669"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.669/agentshield_0.2.669_darwin_amd64.tar.gz"
      sha256 "69fd642c9bd3e7ebc44d3fc908c686c98dc47c5dadc5d29dd90951b0a022a43a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.669/agentshield_0.2.669_darwin_arm64.tar.gz"
      sha256 "54964c77c2cbe990596c2cbc02844275035cc4323a7081abffc0526b8ec1e980"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.669/agentshield_0.2.669_linux_amd64.tar.gz"
      sha256 "9d6df9160b6180643c93da8d1ab083056f8c3cee51374763b4ff7dfa7713aec3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.669/agentshield_0.2.669_linux_arm64.tar.gz"
      sha256 "7479c735e7ef0b30d583aa9477b0a5f2cb3326aee4f7952e6187ead18cc90669"
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
