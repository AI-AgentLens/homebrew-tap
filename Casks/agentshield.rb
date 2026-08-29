cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1983"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1983/agentshield_0.2.1983_darwin_amd64.tar.gz"
      sha256 "6ca72821ed4600d44a18fb868e3ec86d03b873c24932a01ac0cf0f4b337dad18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1983/agentshield_0.2.1983_darwin_arm64.tar.gz"
      sha256 "574520b4e8c0c2aa61c7ca5c3f9722427ef30608ac72ed9d72a8696aaa746346"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1983/agentshield_0.2.1983_linux_amd64.tar.gz"
      sha256 "f84bdf20d757d4e3012e229c5f422f4a4f4c6017e9ec9f3b1ad3e3b1fb7ce5c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1983/agentshield_0.2.1983_linux_arm64.tar.gz"
      sha256 "e6f2132cd34856050cdc184071b12af0c58514da8b17bd19beda223f64c24644"
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
