cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.777"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.777/agentshield_0.2.777_darwin_amd64.tar.gz"
      sha256 "d7eb27a3057d2320e6c8dcbdfd8c998a13f32b72b878ba418609d15258e61580"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.777/agentshield_0.2.777_darwin_arm64.tar.gz"
      sha256 "348c036aae6bdc9789aa7c54c1b22a4ef715671542c1258723529827c81963b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.777/agentshield_0.2.777_linux_amd64.tar.gz"
      sha256 "92801b35b50320a29b28b3c0fb94f57242eb55347a469dc96266ef73eb25d2dc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.777/agentshield_0.2.777_linux_arm64.tar.gz"
      sha256 "127942d7adf71f9edd5d06086bc14458db0f169e1ce69b3c5a3a49b7d9bdbb8e"
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
