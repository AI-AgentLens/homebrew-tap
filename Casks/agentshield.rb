cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.860"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.860/agentshield_0.2.860_darwin_amd64.tar.gz"
      sha256 "a6a7245f2fa7a9268f52558021e4cc84dfd09a44366a4425056cef7f612a995d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.860/agentshield_0.2.860_darwin_arm64.tar.gz"
      sha256 "a9eea7a0bd91542727f62a49f79d7f6b3cd15868c730865efe639541323fe420"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.860/agentshield_0.2.860_linux_amd64.tar.gz"
      sha256 "e00b616c131a913ec9a8a074177d929c980f256cf21d81198a7518a0f178d703"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.860/agentshield_0.2.860_linux_arm64.tar.gz"
      sha256 "ccb1696be450cd9a6a48ca6ea8fe060a6b6c2b5ad06e1decda1fac31af25faf5"
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
