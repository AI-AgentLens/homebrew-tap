cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.305"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.305/agentshield_0.2.305_darwin_amd64.tar.gz"
      sha256 "87a93c0aa3d195ef7966c2804626c10107e077f8a913ccf31b8c039b25f3e403"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.305/agentshield_0.2.305_darwin_arm64.tar.gz"
      sha256 "e5100fee4938dfd002f483b1ba565adcb25401ebccf06d240b5ec220c5c137ee"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.305/agentshield_0.2.305_linux_amd64.tar.gz"
      sha256 "d38044aa509352856b1a5be12912fb32a324f169e8d94c49662049016ca319ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.305/agentshield_0.2.305_linux_arm64.tar.gz"
      sha256 "1f05f17632411e4cd6989cb83c77229f235f1c2ef90e1db4cdd005b2f85d501d"
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
