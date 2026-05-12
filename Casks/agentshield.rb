cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.954"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.954/agentshield_0.2.954_darwin_amd64.tar.gz"
      sha256 "323d05485d5fca559cfcaf67c984fe670a9b278f43d40e8096aea9fcc52ef839"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.954/agentshield_0.2.954_darwin_arm64.tar.gz"
      sha256 "03c1e88036b56464921b21685e929c7f405a33c1a64706637215dc74e302e4cb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.954/agentshield_0.2.954_linux_amd64.tar.gz"
      sha256 "f3d8b392befc37038ff9d05066926717ffa0c1e9ae6e5d8122ad72750d87f354"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.954/agentshield_0.2.954_linux_arm64.tar.gz"
      sha256 "98e5f4c1af5d30b50f0a399e937ded13ed4ff0424cf5c3c95d3d2594ab283723"
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
