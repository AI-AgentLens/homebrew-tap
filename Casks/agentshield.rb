cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1120"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1120/agentshield_0.2.1120_darwin_amd64.tar.gz"
      sha256 "17414eef6b7df9b1ff281d2243bd7eca750da0b0da00db82e777742a8e480141"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1120/agentshield_0.2.1120_darwin_arm64.tar.gz"
      sha256 "d787c7e247d3fc0a4de5a1b5f197b64ac08b41b42345ac519aabef263dbe8b3d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1120/agentshield_0.2.1120_linux_amd64.tar.gz"
      sha256 "f8cc4cd9f49a987fce3ec465eaf9a136470c11a08b96d9164886353189fd6f16"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1120/agentshield_0.2.1120_linux_arm64.tar.gz"
      sha256 "ce6dd1019e2e5f8edefb984f134907952528fb6abd4c314f946107e12b012759"
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
