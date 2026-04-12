cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.557"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.557/agentshield_0.2.557_darwin_amd64.tar.gz"
      sha256 "45a051e1c6ab683f82a689538e34a43ea15176f807d16b593307e293347d144f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.557/agentshield_0.2.557_darwin_arm64.tar.gz"
      sha256 "ce311ad77cafe5bdfbb74d933cc26c778bbedbdb3bc47a774a8beb1b4f807170"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.557/agentshield_0.2.557_linux_amd64.tar.gz"
      sha256 "ea6e18317cafe3761e8a3896f446eff7f70c3c8d27ddbb498cc7dd6e360f8739"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.557/agentshield_0.2.557_linux_arm64.tar.gz"
      sha256 "b2d1251e8f6746e1940aed3efab3096ffc66387dbe38265d4b5c710904f748e9"
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
