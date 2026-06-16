cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1338"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1338/agentshield_0.2.1338_darwin_amd64.tar.gz"
      sha256 "4817dffc77835d9d25b1ee08db35c92df47ee96c038242b623b967d3e703aeeb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1338/agentshield_0.2.1338_darwin_arm64.tar.gz"
      sha256 "a7630e56fb29b5bb4fa7e008ba06fbbef4b73a372d9408108deab9d7f6166074"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1338/agentshield_0.2.1338_linux_amd64.tar.gz"
      sha256 "9e5eb24cc17834d1085ec067f436bd6bf8c715b7c4d6f31dfab9adc639ed6248"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1338/agentshield_0.2.1338_linux_arm64.tar.gz"
      sha256 "e491bd20822bfefbfe89e9a3c730526d3ea8de16732c72367e38a2a53acc2b2c"
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
