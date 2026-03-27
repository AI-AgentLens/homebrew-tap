cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.110"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.110/agentshield_0.2.110_darwin_amd64.tar.gz"
      sha256 "13203e2cc047aed2b41354f6d6ff0d956907f6fbcca4fc3304a3214cfb19baab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.110/agentshield_0.2.110_darwin_arm64.tar.gz"
      sha256 "4cebe706d7be85bd37beb449224bf9abb04a3e5098728eb67d894e411624343e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.110/agentshield_0.2.110_linux_amd64.tar.gz"
      sha256 "5c512decd13d091b9fd8f7be6d7d1444d4bc9ffe2f8d5c06cb9290361d87f96f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.110/agentshield_0.2.110_linux_arm64.tar.gz"
      sha256 "4ba9a31a42379b9794f0b24f835555532fed5063d6ac7e8f3e80cad8fa4b858d"
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
