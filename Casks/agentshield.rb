cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.465"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.465/agentshield_0.2.465_darwin_amd64.tar.gz"
      sha256 "ba3f9dffa5d3f9d705ec1e45ae3d52a4a1efef9198f4ba556f78601142100afc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.465/agentshield_0.2.465_darwin_arm64.tar.gz"
      sha256 "3f7c21f172f90d1957bd13603e4898bb3b7156306be3ab9b41a066419ecc2409"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.465/agentshield_0.2.465_linux_amd64.tar.gz"
      sha256 "0aafebb744c87c60a3b7aeaf4d91956f31f5f1159cefdaf8679cf317166f8984"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.465/agentshield_0.2.465_linux_arm64.tar.gz"
      sha256 "7f79463316d62923191a9e572853988cb3d59b769f8d7be9b453d2c2f5664109"
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
