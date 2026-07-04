cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1555"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1555/agentshield_0.2.1555_darwin_amd64.tar.gz"
      sha256 "9b1b87f92eef84a5047d4266d1a13414d5a5ef70aa1b77cf29443937990d11ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1555/agentshield_0.2.1555_darwin_arm64.tar.gz"
      sha256 "d50b17b79fac67ee7ba629dc9c484b040ca5bc52df6b4259d64f2abc1823bf34"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1555/agentshield_0.2.1555_linux_amd64.tar.gz"
      sha256 "bf07a9450d53399f7b35666bd3e1b3438d8d0a197707ddb265264d027010c637"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1555/agentshield_0.2.1555_linux_arm64.tar.gz"
      sha256 "c85f607c218af2701a27ef8c7b0edefebe5404dd672a45889565f098037dfab5"
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
