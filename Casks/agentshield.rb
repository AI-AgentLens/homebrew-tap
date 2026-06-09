cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1255"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1255/agentshield_0.2.1255_darwin_amd64.tar.gz"
      sha256 "310d89d16f750895be068d1497465210686a3d41c06227852c8fb5a1baaeaf28"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1255/agentshield_0.2.1255_darwin_arm64.tar.gz"
      sha256 "c566e791075088a1039c568e91fc45c9cfe58304330727a332f811681e66ede7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1255/agentshield_0.2.1255_linux_amd64.tar.gz"
      sha256 "e92216ed29a4a80fb7dfb7f3402e08e305a501c6df845d8bf9f0bf78f24dad72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1255/agentshield_0.2.1255_linux_arm64.tar.gz"
      sha256 "7b7f7c0fbad61634100dfde4e5628f887fc9cb60a48d7ecfd8c99f59f51ca65a"
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
