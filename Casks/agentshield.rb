cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2109"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2109/agentshield_0.2.2109_darwin_amd64.tar.gz"
      sha256 "d0d36b6834a98688b717a2509a6e95b70b8f743f4c9ba433181bf3fc54e4f3e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2109/agentshield_0.2.2109_darwin_arm64.tar.gz"
      sha256 "64315844384915461b5f97ec59dee103f2dcda2225b737c838de5e323eccdce3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2109/agentshield_0.2.2109_linux_amd64.tar.gz"
      sha256 "3163d920fd0b13eb59b0ccbd76bc35b4fdfc7636c40bde17e4d718d60ba2050f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2109/agentshield_0.2.2109_linux_arm64.tar.gz"
      sha256 "1012b75f0d4dfa6f414d60ac28492dac49a9fec26285a3807373a7eba5831cbc"
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
