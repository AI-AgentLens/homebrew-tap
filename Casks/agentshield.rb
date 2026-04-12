cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.551"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.551/agentshield_0.2.551_darwin_amd64.tar.gz"
      sha256 "04b514f3697eeeab3c00e43cf48db3c03e46d8872e9c9579bcee449aee82ed53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.551/agentshield_0.2.551_darwin_arm64.tar.gz"
      sha256 "da34a53db194d854a8c15f3b45d37f2939617066de5ed389b3aba2857223a7aa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.551/agentshield_0.2.551_linux_amd64.tar.gz"
      sha256 "80a87b0d1bb946682dafbe7da1454426d159143da87a9cc74f334097523a22bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.551/agentshield_0.2.551_linux_arm64.tar.gz"
      sha256 "e5a98d5581abbd3d76cd8069e7c485439ed4bc5b1cc8f1ee1b8cad3b9e207d11"
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
