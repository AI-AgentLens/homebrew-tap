cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1388"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1388/agentshield_0.2.1388_darwin_amd64.tar.gz"
      sha256 "91d4a587b091bd5b8fba4cf5134dc546e5bac0d57b94b2e20a4ffbc51a10fec5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1388/agentshield_0.2.1388_darwin_arm64.tar.gz"
      sha256 "2224dc2f4631a9386279153fc7977e0859bffdaef367d981d5c611f7c9c6ddc6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1388/agentshield_0.2.1388_linux_amd64.tar.gz"
      sha256 "241aa095bdfd34d5204565e9e555218b1fb4c3f9e62616c5dc759e9b991299d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1388/agentshield_0.2.1388_linux_arm64.tar.gz"
      sha256 "a160de648c1537c158e3f19674034916eb3b57830aff51f7798af8a6aa696a6b"
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
