cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.663"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.663/agentshield_0.2.663_darwin_amd64.tar.gz"
      sha256 "550bcddb0d6a1e9d9b2ab186965597aac76fd52f3ee3e8e3866bcee1a652b8ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.663/agentshield_0.2.663_darwin_arm64.tar.gz"
      sha256 "41fed75469c446c8b5b837fac6dd1f7d0aa392fadd1a345c1ae6775bbe057dec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.663/agentshield_0.2.663_linux_amd64.tar.gz"
      sha256 "7b06eb197a116ae1b7ca6f6401e2bd8af1f6685907dfc350d423a5e44454f10d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.663/agentshield_0.2.663_linux_arm64.tar.gz"
      sha256 "dd0ec51910f4ea625ab190bbcd316b0a79c5e60434efdd55be6c41cc44de887e"
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
