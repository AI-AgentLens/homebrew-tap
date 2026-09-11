cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2115"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2115/agentshield_0.2.2115_darwin_amd64.tar.gz"
      sha256 "71810c5ce9f2a55c0d3c580aa95ca48f8d9d28289014ee340f7243a6d02696fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2115/agentshield_0.2.2115_darwin_arm64.tar.gz"
      sha256 "01b640e7e4fcdb1727916ec2ee4274bbe62ca47b4705b958df1fa19d0940fb79"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2115/agentshield_0.2.2115_linux_amd64.tar.gz"
      sha256 "855f7f61576a1376dbf4be47d9ee6dcb6e0849c475b085fe83d09c6cd5bd5f8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2115/agentshield_0.2.2115_linux_arm64.tar.gz"
      sha256 "d952417538bfe0153d7708ce410dba894b5fb04d567d85f6221864a42819833e"
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
