cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1348"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1348/agentshield_0.2.1348_darwin_amd64.tar.gz"
      sha256 "bfbce2aec6aa1c80c92d457abbfa24d9d74baf7d07ac11915895db634ee32ae7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1348/agentshield_0.2.1348_darwin_arm64.tar.gz"
      sha256 "7b9da3c76cb40f4db98123162f1d7a0acc72e1d891c1a71e3027b27da259203f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1348/agentshield_0.2.1348_linux_amd64.tar.gz"
      sha256 "02d8b5552257476b3bf93b56fb91d83d5a224b446c8760adc069f58c0fb3ccd8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1348/agentshield_0.2.1348_linux_arm64.tar.gz"
      sha256 "11be03ba1bc7fc80d877609b25ab31c5b65e9a53f82e2937db61cedeafb9c272"
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
