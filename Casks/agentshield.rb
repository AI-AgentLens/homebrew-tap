cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2024"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2024/agentshield_0.2.2024_darwin_amd64.tar.gz"
      sha256 "3654c7d206a225c2bedc9ead5fb1ddfba630298213fb5b97b90479ccd5cebe41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2024/agentshield_0.2.2024_darwin_arm64.tar.gz"
      sha256 "e45f3a2b537f3536cecd82bd62f8d830ba06ffd9b0702cef9a19a476129d8a3f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2024/agentshield_0.2.2024_linux_amd64.tar.gz"
      sha256 "41b3f0c645ae3b214dc844d920df3c3e4d26aaea3df6f51edee203ffc5a24b98"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2024/agentshield_0.2.2024_linux_arm64.tar.gz"
      sha256 "db873ab0dbcbfb671581d8fa4334310871074a4da5f57cf783582d68f781af11"
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
