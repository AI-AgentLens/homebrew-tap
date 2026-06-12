cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1293"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1293/agentshield_0.2.1293_darwin_amd64.tar.gz"
      sha256 "8faac3683cb04d03682159cb671f36fe7b9f492ec0ca57c524bd8f6f72f13d8d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1293/agentshield_0.2.1293_darwin_arm64.tar.gz"
      sha256 "6755d874e5276dcfdb2046ed322331c248a2141a6cf520fe15eed40ebff184d1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1293/agentshield_0.2.1293_linux_amd64.tar.gz"
      sha256 "7f96ead81b056453667027471f06832fbc4f4e04f178bde39ce2c4358da7004a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1293/agentshield_0.2.1293_linux_arm64.tar.gz"
      sha256 "048248c2a5f07920d33d71a16f9dd39d69eb8e7a0818183d1578a314627d48ee"
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
