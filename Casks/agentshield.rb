cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1568"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1568/agentshield_0.2.1568_darwin_amd64.tar.gz"
      sha256 "82a40942dd33539bd117540ef1ab8ae704c572ed5086e100f174153b1d7a4909"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1568/agentshield_0.2.1568_darwin_arm64.tar.gz"
      sha256 "86c731cd3972dc88aaf57902089bc6ebd9c78aca237141ce8209df2dff93d37d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1568/agentshield_0.2.1568_linux_amd64.tar.gz"
      sha256 "cb17aa2ffd535d00b4460b94a802ee93dcfa504bfe329cada588db7d13275a65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1568/agentshield_0.2.1568_linux_arm64.tar.gz"
      sha256 "441026d7c352c5ad7be4dd4dacffcf981871abf465f769c4d3501bc5469661b7"
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
