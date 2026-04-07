cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.450"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.450/agentshield_0.2.450_darwin_amd64.tar.gz"
      sha256 "6e837ea55bb2ff3fa30e1501a90fb9a1957eb4bce3a556673b3a5e12f4731c28"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.450/agentshield_0.2.450_darwin_arm64.tar.gz"
      sha256 "54248e98d8afcb350dc496ad6471c70c34b65bd585acdb85d64729bc85c0b5f5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.450/agentshield_0.2.450_linux_amd64.tar.gz"
      sha256 "4488482ee75b8b47822cf5b3def4107d2b71c85eaa94eb8f94ae7d8547e0da0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.450/agentshield_0.2.450_linux_arm64.tar.gz"
      sha256 "954f2d037c3ffd346c16d6c1b202bcfd20fa4f2fb621595e7a3a6d25907f25f4"
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
