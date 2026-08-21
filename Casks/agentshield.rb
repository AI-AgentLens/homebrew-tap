cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1921"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1921/agentshield_0.2.1921_darwin_amd64.tar.gz"
      sha256 "afe84a7f8ec9240d891ccd786781c78f9fe30fbc4497cc4a9dfd331f4f93af8a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1921/agentshield_0.2.1921_darwin_arm64.tar.gz"
      sha256 "a08dcd486753fd62599a3cbec0abdf28d7abd3d3e203edf485ca3e1fc1588594"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1921/agentshield_0.2.1921_linux_amd64.tar.gz"
      sha256 "ee45ecb911a267fb4fd82638ba4fe371a1b5978e0ea0f23c3ca783484004da05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1921/agentshield_0.2.1921_linux_arm64.tar.gz"
      sha256 "b184434f2552c552d507342daecc0c8d7f350d15e888bbfaaeba61ed429630df"
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
