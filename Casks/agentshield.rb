cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.680"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.680/agentshield_0.2.680_darwin_amd64.tar.gz"
      sha256 "66d0a1b19f88480cfb3ebb0abf58adc6b652ddd6be27b3e234984d200a10ef79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.680/agentshield_0.2.680_darwin_arm64.tar.gz"
      sha256 "c614d78d01a62722c482e20d17947bf19018bebd389489c8e77fb94e23efd735"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.680/agentshield_0.2.680_linux_amd64.tar.gz"
      sha256 "36442dbe63aa9340f9186db267ca72ab7e7aba010273b41aed46405279bed7cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.680/agentshield_0.2.680_linux_arm64.tar.gz"
      sha256 "427891a799fd405ad03d885e7ab9c79270cf4ea3c6c99f53586423de5bd11089"
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
