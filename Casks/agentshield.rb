cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1696"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1696/agentshield_0.2.1696_darwin_amd64.tar.gz"
      sha256 "f01c79f0ec22c4c581e5191881386adb5f98362cf2d3f5e773a45d709aa22291"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1696/agentshield_0.2.1696_darwin_arm64.tar.gz"
      sha256 "56f53d12754e48168e2baac57970c04425287968aa0d2f09d2407c2782764825"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1696/agentshield_0.2.1696_linux_amd64.tar.gz"
      sha256 "3f497ee42cdbc978cf23920e7a069bfb9e55e3aa94654926d2d8dd806923fa65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1696/agentshield_0.2.1696_linux_arm64.tar.gz"
      sha256 "0b206bfcdd3fec30912414c825f47641a295ac644b937a851a942f0ca1d08ced"
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
