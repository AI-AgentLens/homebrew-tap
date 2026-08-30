cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1992"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1992/agentshield_0.2.1992_darwin_amd64.tar.gz"
      sha256 "12e53ed9579a87531ebdea87ce665f9b18f7fbaeee65c7177e6e23cdafbd1664"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1992/agentshield_0.2.1992_darwin_arm64.tar.gz"
      sha256 "02aa85f5fdbceda388ddd1418bc9a7411fa82eef116469941e024884cede52fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1992/agentshield_0.2.1992_linux_amd64.tar.gz"
      sha256 "34484cd9d4570e6f7d9e1f283f295267e0ec6ae3796393d1b4d80f7aebc419fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1992/agentshield_0.2.1992_linux_arm64.tar.gz"
      sha256 "dc5af08a539e422299d55a093c05b63284d371b10cfa25772971ff9af690325c"
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
