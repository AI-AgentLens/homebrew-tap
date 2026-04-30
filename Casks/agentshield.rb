cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.831"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.831/agentshield_0.2.831_darwin_amd64.tar.gz"
      sha256 "6a63141c7a876409161ae9c04e748509d8c2a14232da648360938c4729542005"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.831/agentshield_0.2.831_darwin_arm64.tar.gz"
      sha256 "3e1cf93bd2301173ab95b450322fab603961d53b7c98e6559a728bbae58ffb6e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.831/agentshield_0.2.831_linux_amd64.tar.gz"
      sha256 "b520db9dca5ef92014fefe40c100e68b150f8ec43f6d24b733b681c2336cc036"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.831/agentshield_0.2.831_linux_arm64.tar.gz"
      sha256 "b69ed87455409b2c98e77529c72b84f6e6ffaa50ad12ba0a6cec133d1377e2c3"
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
