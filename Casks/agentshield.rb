cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.357"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.357/agentshield_0.2.357_darwin_amd64.tar.gz"
      sha256 "40792bef710225a2ad489f45ee048146a48842a8089f1f6677ba89447ecb5f4e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.357/agentshield_0.2.357_darwin_arm64.tar.gz"
      sha256 "a57e3b80cfadc08e0c40f03a51e7b0b199c7204fcea737a54433545a4ec753a8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.357/agentshield_0.2.357_linux_amd64.tar.gz"
      sha256 "dd7f31d703a8fadd1f2e82013a7712691a29f95f70932c7c26ea98727ca966e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.357/agentshield_0.2.357_linux_arm64.tar.gz"
      sha256 "2d3ea525a6c2aa583bc9d11b8b2b033919aa7c14d9d0abd430ffdc9cde1800c8"
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
