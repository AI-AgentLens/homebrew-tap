cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1834"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1834/agentshield_0.2.1834_darwin_amd64.tar.gz"
      sha256 "c4c82515ec474a745331ed1ec365341253aba4ee918a5745c39a4e02e16db179"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1834/agentshield_0.2.1834_darwin_arm64.tar.gz"
      sha256 "56150973b36eccf157396ceba20393ba0ba4977ec53ad54a2591c4482f1dda4a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1834/agentshield_0.2.1834_linux_amd64.tar.gz"
      sha256 "51c635869013f23cec1ca4c46f449aacf178aa30923dae0cc1ddf207d05c3897"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1834/agentshield_0.2.1834_linux_arm64.tar.gz"
      sha256 "160fe2824892b2900db63c2b4c42893a48fb75b1cf50c0f03b3de1510c980f7a"
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
