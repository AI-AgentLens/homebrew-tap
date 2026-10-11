cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2402"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2402/agentshield_0.2.2402_darwin_amd64.tar.gz"
      sha256 "74ed241f054ce3fb472bea591e0468503653248c9a90ce7ce827f7a59d9c31f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2402/agentshield_0.2.2402_darwin_arm64.tar.gz"
      sha256 "804da20236ae0e7170d677115b2327be755aab2ddfc3acc7b28b687a0e2fc5ed"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2402/agentshield_0.2.2402_linux_amd64.tar.gz"
      sha256 "f2a66bcb563c2eba4a671c4abdfddc993aa523226e7f28874f485a6ae1b4c059"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2402/agentshield_0.2.2402_linux_arm64.tar.gz"
      sha256 "90b0353c84c99c79bd4d4218eb7fb7babb8d3ccb7dc68cb9267e06a9120f5e39"
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
