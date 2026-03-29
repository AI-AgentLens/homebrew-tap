cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.219"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.219/agentshield_0.2.219_darwin_amd64.tar.gz"
      sha256 "d1b5ee1908839e8833320ab31a72a3db0ae8e4aa644d786e30af756fefe6c6fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.219/agentshield_0.2.219_darwin_arm64.tar.gz"
      sha256 "1671615b8aa7730b74e0ad0adac67ee44c25083501cc95d7a896f2adfc1c6409"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.219/agentshield_0.2.219_linux_amd64.tar.gz"
      sha256 "927fb0f9281f07d472670dedcd2cafad40844d1aa9e338129921856233a2976d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.219/agentshield_0.2.219_linux_arm64.tar.gz"
      sha256 "6d6e50acd4415dc571aee92993e037aa1e156ebf4ac2f34ef5749348de9388f3"
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
