cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1654"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1654/agentshield_0.2.1654_darwin_amd64.tar.gz"
      sha256 "4a4af6bb8541a2224dfcf269fc3a406889d94370b1ea0726c1b71546983ab246"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1654/agentshield_0.2.1654_darwin_arm64.tar.gz"
      sha256 "a82773df68908c13488574f900670611c593a532daa98d2334ec6c2ab5034d78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1654/agentshield_0.2.1654_linux_amd64.tar.gz"
      sha256 "593b8aaec1e596727b601ef5f3d26701b0d3e8359fa71f66a890991e4f8e3c89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1654/agentshield_0.2.1654_linux_arm64.tar.gz"
      sha256 "090ad76aefd28e2bda7070755cc685bce89affe35d3aad1b24e70ae5fad0efb4"
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
