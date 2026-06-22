cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1403"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1403/agentshield_0.2.1403_darwin_amd64.tar.gz"
      sha256 "4dade004f469f39faf08b63ce1780ba448c26c241dcfcabe25943e6730c087c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1403/agentshield_0.2.1403_darwin_arm64.tar.gz"
      sha256 "d32073f5e1bc84f84626c2a077464c0c2b798348de4df31c9661de54178865d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1403/agentshield_0.2.1403_linux_amd64.tar.gz"
      sha256 "b50874fedeebc20d77ae157d1c779787d33baf105be15a9811b4ce29c485f4c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1403/agentshield_0.2.1403_linux_arm64.tar.gz"
      sha256 "f37b914d488040cd0110e18dd232466de13898548abb923c4b7fb4500c1f0367"
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
