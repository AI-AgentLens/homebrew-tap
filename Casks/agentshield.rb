cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1852"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1852/agentshield_0.2.1852_darwin_amd64.tar.gz"
      sha256 "a36ee7415b9d0b1f23d38101f9c8aa6113334b00ac3d3c3c1af6a2d9543917f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1852/agentshield_0.2.1852_darwin_arm64.tar.gz"
      sha256 "99f2341e221eb9bd2ad528cc695ff5f6bee26cc61be41138f39cf2575f928deb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1852/agentshield_0.2.1852_linux_amd64.tar.gz"
      sha256 "54ac2681acc855c75b740e0ea21420a35633530353936d60efcd3698243c2252"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1852/agentshield_0.2.1852_linux_arm64.tar.gz"
      sha256 "45f6f77433403d7518fa3c256fa1a80f7fbb0f01f33b8cfe75b36afbd850e1b0"
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
