cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1501"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1501/agentshield_0.2.1501_darwin_amd64.tar.gz"
      sha256 "68f90a88ad2cef3feabe5c6ca4517cc0e7fc4425c3758ac274eff6ac1b6f2cc8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1501/agentshield_0.2.1501_darwin_arm64.tar.gz"
      sha256 "da915fbdb89896f470ab642a4e294149b8ebc6049847999cbf4774a2a9240655"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1501/agentshield_0.2.1501_linux_amd64.tar.gz"
      sha256 "ecf0871781457792fdd69727fc4207824db6b48545eb06299ac1914adee39692"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1501/agentshield_0.2.1501_linux_arm64.tar.gz"
      sha256 "38adfcf4498fff4991798458495a42f7db102f6527ed0fe755175edb03dce208"
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
