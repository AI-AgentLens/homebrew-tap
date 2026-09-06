cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2059"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2059/agentshield_0.2.2059_darwin_amd64.tar.gz"
      sha256 "d93deba89f043b4ba7e1f1e725e2e6c4f914b3290500ce50ab176c9ff1b64e60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2059/agentshield_0.2.2059_darwin_arm64.tar.gz"
      sha256 "67e8e82b24c15de9764dc8e84426d6b01bff5dcb5acf339994885e93e6a0a734"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2059/agentshield_0.2.2059_linux_amd64.tar.gz"
      sha256 "d0a172af0018195be748b0a6689deab90fd9b0539e8ace3910bf56aa784043a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2059/agentshield_0.2.2059_linux_arm64.tar.gz"
      sha256 "34389de765a792bc01470eeb1e01118bb1ca90f61abfe670893caaf3b912ccb4"
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
