cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1887"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1887/agentshield_0.2.1887_darwin_amd64.tar.gz"
      sha256 "ec1fdc7435f3013a49a0aa1e736c33ba1c80f8d4f37de21097ab5fb2f1f4b5eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1887/agentshield_0.2.1887_darwin_arm64.tar.gz"
      sha256 "bf3cd7d1434a3b3dd8411b14dc191f73af58d77655482ff220f8818658b2707c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1887/agentshield_0.2.1887_linux_amd64.tar.gz"
      sha256 "f422da37ea4fc1e13f6011d4ac7f9d8932f4f966df374be4bf24003c3b39c1da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1887/agentshield_0.2.1887_linux_arm64.tar.gz"
      sha256 "a70c1895702e812b9c45862ca1325e6043e9f273d74779ad4173ab43332def1f"
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
