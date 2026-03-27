cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.122"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.122/agentshield_0.2.122_darwin_amd64.tar.gz"
      sha256 "57573feadd97c1b1641af347da5a53b13844d228453fbd50a7ea03cbee99a3c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.122/agentshield_0.2.122_darwin_arm64.tar.gz"
      sha256 "a72e91b948b527242e8033e5419b10299a52a9ae0834378e21a78886b5d0b554"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.122/agentshield_0.2.122_linux_amd64.tar.gz"
      sha256 "444ae4a095dca726109933a658ce3da04f4e8569d3a80645ef8b7ae8ac452e36"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.122/agentshield_0.2.122_linux_arm64.tar.gz"
      sha256 "57cdd66c7224f349732835cb7744d9f207028741bbc892bb84bbae7892bc0791"
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
