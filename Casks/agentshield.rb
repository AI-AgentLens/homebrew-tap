cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1424"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1424/agentshield_0.2.1424_darwin_amd64.tar.gz"
      sha256 "fede82dad64780fdf8d581973940f27f79a22903167b1181a55d96cf9c7bb7bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1424/agentshield_0.2.1424_darwin_arm64.tar.gz"
      sha256 "79dbb50f638767a0966e661fe4621f8b83d19d2705221e6904a982d5cfadd4b0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1424/agentshield_0.2.1424_linux_amd64.tar.gz"
      sha256 "1995f68c8be0d3273eebe921ee99fac352d7070f01d464412a44cc2118e6211b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1424/agentshield_0.2.1424_linux_arm64.tar.gz"
      sha256 "9facf602c01a53b094e17f15f70a9d2eb21a8414487e664b7615537471ee5aa3"
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
