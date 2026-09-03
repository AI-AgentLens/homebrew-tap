cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2033"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2033/agentshield_0.2.2033_darwin_amd64.tar.gz"
      sha256 "8615232dae87fc441d24652fa802ea72157d5ca32ee047d07bd85a8db25d07a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2033/agentshield_0.2.2033_darwin_arm64.tar.gz"
      sha256 "ece398f9022a054dd156e9c3dbe158c73ac81942b36586087fc6d688057ab087"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2033/agentshield_0.2.2033_linux_amd64.tar.gz"
      sha256 "6dfdff7a01ac9516798fd79171f00ffa05350a65602567334acb0575ee767aa9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2033/agentshield_0.2.2033_linux_arm64.tar.gz"
      sha256 "72f5e6901fac087e2aff7f81a02fb99cc3924afdb57082fb74e3aaedb39d5375"
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
