cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2232"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2232/agentshield_0.2.2232_darwin_amd64.tar.gz"
      sha256 "4cdf5c3611e7d30712d645f146df1cef0a7ed08b6672f07f5793a4157fdb6ea0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2232/agentshield_0.2.2232_darwin_arm64.tar.gz"
      sha256 "17bc20659d2cc20bb2574ed089265734e523c1af2fb6d79caff5f8aca982a8f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2232/agentshield_0.2.2232_linux_amd64.tar.gz"
      sha256 "50a305e25434920683ea182d223769f95a131efaa1cc7dcd655ca5d15c1697d4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2232/agentshield_0.2.2232_linux_arm64.tar.gz"
      sha256 "863d0fcd8d40339c3043e7c8a0c3e598685b50d3c2ad19f507cf84c27ce3f36b"
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
