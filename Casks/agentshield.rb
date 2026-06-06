cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1224"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1224/agentshield_0.2.1224_darwin_amd64.tar.gz"
      sha256 "51c74a651a5e30a30794f26f8a3ffbbbfe14f4784246312e15cda732b5e2c236"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1224/agentshield_0.2.1224_darwin_arm64.tar.gz"
      sha256 "166e5689836a77a791dead8a58c86d0ea2c3beb2b52efff3361acd1a053d0146"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1224/agentshield_0.2.1224_linux_amd64.tar.gz"
      sha256 "c943a7dd71b0c01ca44b46ec7e285dd4094ebfc1b080a50ca105ced45fa5b58f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1224/agentshield_0.2.1224_linux_arm64.tar.gz"
      sha256 "190f1438f00fb93b57eae53f68f78963be0c2b54ab412f5adea2d1694f17e6f6"
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
