cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2267"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2267/agentshield_0.2.2267_darwin_amd64.tar.gz"
      sha256 "ed918397666ea49ce71368c38bf90f33d2e215c1fcbf1382670c607522bc6e8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2267/agentshield_0.2.2267_darwin_arm64.tar.gz"
      sha256 "a06f51dc0b55b0e43c4917041b799622c55522426708246473718ae519e16d72"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2267/agentshield_0.2.2267_linux_amd64.tar.gz"
      sha256 "d6dc3cfb2306e94cf3db09fab17dc48c445a0a1712eccdc1debfbf96d5b961d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2267/agentshield_0.2.2267_linux_arm64.tar.gz"
      sha256 "d1c58773dfdc4f8c0486be5520d1da20973f22edbd45c1194cd38ab6ecd5081b"
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
