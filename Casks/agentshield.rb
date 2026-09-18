cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2176"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2176/agentshield_0.2.2176_darwin_amd64.tar.gz"
      sha256 "3393d5e5d3e0a9ecbbdb5e1ba3789f34649c07fede0a7c378d9ad9774584fbfd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2176/agentshield_0.2.2176_darwin_arm64.tar.gz"
      sha256 "f5a99c48749dcff52049c1d09cefb11daa19e545d5b70612196a7735706043d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2176/agentshield_0.2.2176_linux_amd64.tar.gz"
      sha256 "86f8843cadcc8e3427fec986bd3f6f9b2f35dd48301145069f847f7d885549d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2176/agentshield_0.2.2176_linux_arm64.tar.gz"
      sha256 "bef516e9a2b1f06bb22f7c0d8fad96f7804259348ab713c1570c9436299cdc8b"
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
